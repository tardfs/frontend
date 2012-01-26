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
* Filename:     main.c
*
* Description:
* An example application which accesses PHY registers:
* - PHY ID registers are displayed
* - 1000MB Autonegotiation is disabled
* - The results of autonegotiation are displayed
*
*
* MODIFICATION HISTORY:
*
* Ver    Who   Date     Changes
* ------ ----  -------- -------------------------------------------------------
* 1.00.a bhill 3/6/2008 Initial release
*
*
* $Id: main.c,v 1.1 2007/11/14 22:37:42 bhill Exp $
******************************************************************************/

/***************************** Include Files *********************************/
// Located in: ppc405_0/include/xparameters.h
#include "xparameters.h"

#include "stdio.h"
#include "xutil.h"

#include "mii-bitbang.h"
#include "marvell_88e1111.h"

/************************** Constant Definitions *****************************/
/*
 * The MII address of the PHY on the board this software will run on
 * ML403
 */
#define PHY_ADDR   0

#define PHY_IDO_REG  2
#define PHY_ID1_REG  3

/*
 * GPIO Connected to PHY MDC/MDIO pins.
 */
XGpio mii_gpio;

/*
 * main:
 */
int main (void) {
   u16   val, phy_id;

   xil_printf("\n\rDemonstration of PHY register access with GPIOs:\n\r");

   /*
    * Initialize the GPIO
    */
   MiiGpio_Init(&mii_gpio);

   /*
    * Set the PHY access functions to the GPIO Bitbang functions.
    */
   marvell_phy_setvectors((PhyRead_t*)MiiGpio_PhyRead,
                          (PhyWrite_t*)MiiGpio_PhyWrite);

   phy_id = PHY_ADDR;
   xil_printf("Read from phy %d\n\r", phy_id);
   MiiGpio_PhyRead(&mii_gpio, phy_id, PHY_IDO_REG, &val);
   xil_printf("REG %d: 0x%04x\n\r", PHY_IDO_REG, val);
   MiiGpio_PhyRead(&mii_gpio, phy_id, PHY_ID1_REG, &val);
   xil_printf("REG %d: 0x%04x\n\r", PHY_ID1_REG, val);

   /*
    * Verify that a Marvell PHY is present
    */
   val = marvell_phy_detected(&mii_gpio, PHY_ADDR);
   if (val == XFALSE) { 
       print("Marvell PHY not detected.\n\r");
       return 1;
   }

   /*
    * Wait for autonegotiation to complete.
    */
   printf("Waiting for auto-negotiation to complete.\n\r");
   do {
       val = marvell_phy_link_status(&mii_gpio, PHY_ADDR);
   } while (val == XFALSE);

   /*
    * Display present results of auto-negotiation.
    */
   marvell_phy_display_status(&mii_gpio, PHY_ADDR);

   printf("Disableing 1000MB and initiating re-negotiation.\n\r");
   marvell_phy_set_1000mb_autoneg(&mii_gpio, PHY_ADDR, XFALSE);
   
   /*
    * Wait for autonegotiation to complete.
    */
   printf("Waiting for auto-negotiation to complete.\n\r");
   do {
       val = marvell_phy_link_status(&mii_gpio, PHY_ADDR);
   } while (val == XFALSE);
 
   /*
    * Display new results of auto-negotiation.
    */
   marvell_phy_display_status(&mii_gpio, PHY_ADDR);

   return 0;
}

