/**************************************************************************
*
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
*     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
*     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
*     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS
*     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*     FOR A PARTICULAR PURPOSE.
*
*     (c) Copyright 2008 Xilinx, Inc.
*     All rights reserved.
*
**************************************************************************/

/**************************************************************************
* Filename:     mii-bitbang.c
*
* Description:
* Software to access PHY registers in a system where the serial control bus
* signals (MDC, MDIO) are connected to GPIO. The code derived from Linux 2.6
* drivers/net/fs_enet/ driver.
*
*
* MODIFICATION HISTORY:
*
* Ver    Who   Date     Changes
* ------ ----- -------- -----------------------------------------------------
* 1.00.a bhill 3/6/2008 Initial release
*
*
* $Id: mii-bitbang.c,v 1.1 2007/11/14 22:37:42 bhill Exp $
******************************************************************************/

/***************************** Include Files *********************************/
#include "xparameters.h"
#include "sleep.h"

#include "mii-bitbang.h"

/************************** Constant Definitions *****************************/
#define MDC_MDIO_DEVICE_ID     XPAR_MII_MDC_MDIO_DEVICE_ID
#define MDC_MDIO_GPIO_CHANNEL  1

/*
 * Which GPIO bit is MDC and which is MDIO are determined by:
 *
 * From system.mhs:
 * PORT fpga_0_MII_MDC_MDIO_GPIO_IO_pin = fpga_0_MII_MDC_MDIO_GPIO_IO,
 *                                        DIR = IO, VEC = [1:0]
 *
 * From ML403 data/system.ucf:
 * # MDIO
 * Net fpga_0_MII_MDC_MDIO_GPIO_IO_pin<1> LOC = G4;
 * # MDC
 * Net fpga_0_MII_MDC_MDIO_GPIO_IO_pin<0> LOC = D1;
 */
#define MDC_MDIO_MDIO_BIT       2
#define MDC_MDIO_MDIO_BIT_SHIFT 1
#define MDC_MDIO_MDC_BIT        1
#define MDC_MDIO_MDC_BIT_SHIFT  0

/*****************************************************************/
#define MII_READ                1
#define MII_WRITE               0
#define MII_PREABLE_BITS        32
#define MII_5ADDRESS_BITS       5
#define MII_16REGISTER_BITS     16
#define MII_DATA_INVALID        0xFFFF
#define FIFTH_BIT_0x10          0x10
#define MSB_16BITS_0x8000       0x8000

/*****************************************************************/


/*
 * mii_delay:
 * Pause a bit.
 */
static inline void
mii_delay (void)
{
#ifdef CPU_SPINLOOP_DELAY
    int i;
    for (i=0; i<1000; i++) { ; }
#else
    /*
     * Target MDC Frequency of 1/(2*1us) -- 500KHz 
     */
    usleep(1);
#endif
}

/*
 * mdio_mode_output:
 * set GPIO to OUTPUT
 */
static inline void
mdio_mode_output (XGpio *mii_gpio)
{
    u32 dir;

    dir = XGpio_GetDataDirection(mii_gpio, MDC_MDIO_GPIO_CHANNEL);
    dir &= ~MDC_MDIO_MDIO_BIT;

    /* Set the direction for the MDIO signal to be output */
    XGpio_SetDataDirection(mii_gpio, MDC_MDIO_GPIO_CHANNEL, dir);
}

/*
 * mdio_mode_input:
 * set GPIO to INPUT
 */
static inline void
mdio_mode_input (XGpio *mii_gpio)
{
    u32 dir;

    dir = XGpio_GetDataDirection(mii_gpio, MDC_MDIO_GPIO_CHANNEL);
    dir |= MDC_MDIO_MDIO_BIT;

    /* Set the direction for the MDIO signal to be input */
    XGpio_SetDataDirection(mii_gpio, MDC_MDIO_GPIO_CHANNEL, dir);
}

/*
 * mdio_read:
 * Read the value presently driven by the PHY on the MDIO GPIO
 */
static inline int
mdio_read (XGpio *mii_gpio)
{
    u32 data;

    data = XGpio_DiscreteRead(mii_gpio, MDC_MDIO_GPIO_CHANNEL);
    return ((data & MDC_MDIO_MDIO_BIT) >> MDC_MDIO_MDIO_BIT_SHIFT);
}

/*
 * mdio_drive_bit:
 * set the GPIO to drive the appropriate bit value on the MDIO pin
 */
static inline void
mdio_drive_bit (XGpio *mii_gpio, u32 value)
{
    if (value) {
        XGpio_DiscreteSet(mii_gpio, MDC_MDIO_GPIO_CHANNEL, MDC_MDIO_MDIO_BIT);
    } else {
        XGpio_DiscreteClear(mii_gpio, MDC_MDIO_GPIO_CHANNEL,
                            MDC_MDIO_MDIO_BIT);
    }
}

/*
 * mdc_drive_bit:
 * Toggle the MDC GPIO to the appropriate bit.
 */
static inline void
mdc_drive_bit (XGpio *mii_gpio, u32 value)
{
    if (value) {
        XGpio_DiscreteSet(mii_gpio, MDC_MDIO_GPIO_CHANNEL, MDC_MDIO_MDC_BIT);
    } else {
        XGpio_DiscreteClear(mii_gpio, MDC_MDIO_GPIO_CHANNEL, MDC_MDIO_MDC_BIT);
    }
}

/*
 * mdc_clk_1_0:
 * Drive the MII Data Clock 1->0
 */
static inline void
mdc_clk_1_0 (XGpio *mii_gpio)
{
    mii_delay();
    mdc_drive_bit(mii_gpio, 1);
    mii_delay();
    mdc_drive_bit(mii_gpio, 0);
}

/*
 * mii_send_address:
 * Transmit the preamble, phy address, and phy register number on the bus.
 */
static void
mii_send_address (XGpio *mii_gpio, int read, u8 addr, u8 reg)
{
    int i;

    /*
     * Send a 32 bit preamble of 1's
     */
    mdio_mode_output(mii_gpio);
    mdio_drive_bit(mii_gpio, 1);             /* <<<<< */
    for (i = 0; i < MII_PREABLE_BITS; i++) {
        mdc_clk_1_0(mii_gpio);
    }

    /*
     * send the start bit (01)
     */
    mdio_drive_bit(mii_gpio, 0);             /* <<<<< */
    mdc_clk_1_0(mii_gpio);
    mdio_drive_bit(mii_gpio, 1);             /* <<<<< */
    mdc_clk_1_0(mii_gpio);
    /*
     *  send the opcode: read (10) write (10)
     */
    mdio_drive_bit(mii_gpio, read);          /* <<<<< */
    mdc_clk_1_0(mii_gpio);
    mdio_drive_bit(mii_gpio, !read);         /* <<<<< */
    mdc_clk_1_0(mii_gpio);

    /*
     * send the PHY address
     */
    for (i = 0; i < MII_5ADDRESS_BITS; i++) {
        if (addr & FIFTH_BIT_0x10) { 
             mdio_drive_bit(mii_gpio, 1);     /* <<<<< */
        } else {
             mdio_drive_bit(mii_gpio, 0);     /* <<<<< */
        }
        mdc_clk_1_0(mii_gpio);

        addr <<= 1;
    }

    /*
     * send the register address
     */
    for (i = 0; i < MII_5ADDRESS_BITS; i++) {
        if (reg & FIFTH_BIT_0x10) {
            mdio_drive_bit(mii_gpio, 1);      /* <<<<< */
        } else {
            mdio_drive_bit(mii_gpio, 0);      /* <<<<< */
        }
        mdc_clk_1_0(mii_gpio);

        reg <<= 1;
    }
}

/*
 * MiiGpio_PhyRead:
 * Read from an MII PHY register
 */
void
MiiGpio_PhyRead (XGpio *mii_gpio, u32 PhyAddress, u32 RegisterNum,
                 u16 *PhyDataPtr)
{
    u16 regval;
    u16 i;

    if (PhyDataPtr == NULL) {
        return;
    }
    *PhyDataPtr = MII_DATA_INVALID;
    if (mii_gpio == NULL) {
        return;
    }

    /*
     * Bang the PHY address and PHY register on the bus.
     */
    mii_send_address(mii_gpio, MII_READ, PhyAddress, RegisterNum);

    /*
     * Set GPIO mode to read
     */
    mdio_mode_input(mii_gpio);
    mdc_clk_1_0(mii_gpio);

    /*
     * check the turnaround bit
     */
    if (mdio_read(mii_gpio) != 0) {              /* >>>>>>>> */
        xil_printf("%s ERROR: PHY not driving turnaround bit low.\n\r",
                   __FUNCTION__);
        *PhyDataPtr = MII_DATA_INVALID;
        return;
    }

    /*
     * read 16 bits of register data, MSB first
     */
    regval = 0;
    for (i = 0; i < MII_16REGISTER_BITS; i++) {
        mdc_clk_1_0(mii_gpio);

        regval <<= 1;
        regval |= mdio_read(mii_gpio);            /* >>>>>>>> */
    }

    mdc_clk_1_0(mii_gpio);

    *PhyDataPtr = regval;
}

/*
 * MiiGpio_PhyWrite:
 * Write to an MII PHY register
 */
void
MiiGpio_PhyWrite (XGpio *mii_gpio, u32 PhyAddress, u32 RegisterNum, u16 PhyData)
{
    int i;

    if (mii_gpio == NULL) {
        return;
    }

    /*
     * Bang the PHY address and PHY register on the bus.
     */
    mii_send_address(mii_gpio, MII_WRITE, PhyAddress, RegisterNum);

    /* send the turnaround (10) */
    mdio_drive_bit(mii_gpio, 1);            /* <<<<< */
    mdc_clk_1_0(mii_gpio);
    mdio_drive_bit(mii_gpio, 0);            /* <<<<< */
    mdc_clk_1_0(mii_gpio);

    /*
     * write 16 bits of register data, MSB first
     */
    for (i = 0; i < MII_16REGISTER_BITS; i++) {
        if (PhyData & MSB_16BITS_0x8000) {
            mdio_drive_bit(mii_gpio, 1);    /* <<<<< */
        } else {
            mdio_drive_bit(mii_gpio, 0);    /* <<<<< */
        }
        mdc_clk_1_0(mii_gpio);

    	PhyData <<= 1;
    }

    mdio_mode_input(mii_gpio);
    mdc_clk_1_0(mii_gpio);
}

/*
 * MiiGpio_Init:
 * Initialize GPIOs connected to PHY MDC and MDIO pins
 */
XStatus
MiiGpio_Init (XGpio *mii_gpio)
{
    Xuint32 Data;
    XStatus Status;
    volatile int Delay;

    if (mii_gpio == NULL) {
        return XST_INVALID_PARAM;
    }

    /*
     * Initialize the GPIO component
     */
    Status = XGpio_Initialize(mii_gpio, MDC_MDIO_DEVICE_ID);
    if (Status != XST_SUCCESS)
    {
        return Status;
    }

    /*
     * Set the direction for MDC signals to be output
     */
    XGpio_SetDataDirection(mii_gpio, MDC_MDIO_GPIO_CHANNEL, MDC_MDIO_MDIO_BIT);
}
