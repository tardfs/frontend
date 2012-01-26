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
* Filename:     marvell_88e1111.c
*
* Description:
* Routines to control and display the status of a Marvell 88E1111 Ethernet
* PHY.
*
*
* MODIFICATION HISTORY:
*
* Ver    Who   Date     Changes
* ------ ----- -------- -------------------------------------------------------
* 1.00.a bhill 3/6/08   Initial Release
*
*
* $Id: marvell_88e1111.c,v 1.1 2007/11/14 22:37:42 bhill Exp $
******************************************************************************/

/***************************** Include Files *********************************/
#include "xutil.h"
#include "marvell_88e1111.h"


/*
 * Pointers to functions which will read/write the PHY registers.
 * These must be set with marvell_phy_setvectors() before any other functions
 * in this file are called.
 */
static PhyWrite_t *PhyWrite_fp;
static PhyRead_t  *PhyRead_fp;

/*
 * marvell_phy_setvectors:
 * initialize read/write vectors to the driver which will provide access
 * to the PHY registers.
 */
void
marvell_phy_setvectors (PhyRead_t *read_fp, PhyWrite_t *write_fp)
{
    PhyWrite_fp = write_fp;
    PhyRead_fp = read_fp;
}

/*
 * marvell_phy_detected:
 * Returns XTRUE if Marvell PHY detected at PhyAddress, otherwise returns
 * XFALSE.
 */
int
marvell_phy_detected (void *phy_inst, u32 PhyAddress)
{
    u16 val;

    if (PhyRead_fp == NULL) {
        xil_printf("%s ERROR: PHY accessor vectors not set.\n\r",
                   __FUNCTION__);
        return XFALSE;
    }

    (*PhyRead_fp)(phy_inst, PhyAddress, MPHY_ID0_REG, &val);
    if (val == MPHY_ID0_MARVELL_OUI) {
        return XTRUE;
    }
    return XFALSE;
}

/*
 * marvell_phy_set_1000mb_autoneg:
 * Enable or disable the autonegotiation of 1000MB
 */
void
marvell_phy_set_1000mb_autoneg (void *phy_inst, u32 PhyAddress, int Enable)
{
    u16 val;

    if ((PhyRead_fp == NULL) || (PhyWrite_fp == NULL)) {
        xil_printf("%s ERROR: PHY accessor vectors not set.\n\r",
                   __FUNCTION__);
        return;
    }

    /*
     * Change advertised capabilities
     */
    (*PhyRead_fp)(phy_inst, PhyAddress, MPHY_1000BT_CONTROL_REG, &val);
    if (Enable) {
        val |= (MPHY_1000BT_CONTROL_ADV_1000BT_FD |
                MPHY_1000BT_CONTROL_ADV_1000BT_HD);
    } else {
        val &= ~(MPHY_1000BT_CONTROL_ADV_1000BT_FD |
                 MPHY_1000BT_CONTROL_ADV_1000BT_HD);
    }
    (*PhyWrite_fp)(phy_inst, PhyAddress, MPHY_1000BT_CONTROL_REG, val);

    /*
     * Re-negotiate 
     */
    (*PhyRead_fp)(phy_inst, PhyAddress, MPHY_CONTROL_REG, &val);
    val |= MPHY_CONTROL_RSTRT_AUTONEG;
    (*PhyWrite_fp)(phy_inst, PhyAddress, MPHY_CONTROL_REG, val);
}

/*
 * marvell_phy_link_status:
 * Returns XTRUE if LINK is UP
 * Returns XFALSE if LINK is DOWN
 */
int
marvell_phy_link_status (void *phy_inst, u32 PhyAddress)
{
    u16 val;

    if (PhyRead_fp == NULL) {
        xil_printf("%s ERROR: PHY accessor vectors not set.\n\r",
                   __FUNCTION__);
        return XFALSE;
    }

    (*PhyRead_fp)(phy_inst, PhyAddress, MPHY_SPCFC_STATUS_REG, &val);
    if (val & MPHY_SPCFC_STAT_LINK_RT) {
        return XTRUE;
    }
    return XFALSE;
}

/*
 * marvell_phy_display_status:
 */
void
marvell_phy_display_status (void *phy_inst, u32 PhyAddress)
{
    u16 val, speed_status;

    if (PhyRead_fp == NULL) {
        xil_printf("%s ERROR: PHY accessor vectors not set.\n\r",
                   __FUNCTION__);
        return;
    }

    (*PhyRead_fp)(phy_inst, PhyAddress, MPHY_SPCFC_STATUS_REG, &val);
    if (val & MPHY_SPCFC_STAT_LINK_RT) {
        xil_printf("PHY Status: LINK_OK ");
    } else {
        xil_printf("PHY Status: LINK_DOWN\n\r");
        return;
    }

    speed_status = val >> MPHY_SPCFC_STAT_SPD_SHIFT;
    switch (speed_status) {
    case MPHY_SPCFC_STAT_SPD_RESVD:
        xil_printf("SPEED-RESERVED ");
        break;
    case MPHY_SPCFC_STAT_SPD_1000:
        xil_printf("SPEED-1000MB ");
        break;
    case MPHY_SPCFC_STAT_SPD_100:
        xil_printf("SPEED-100MB ");
        break;
    case MPHY_SPCFC_STAT_SPD_10:
        xil_printf("SPEED-10MB ");
        break;
    }

    if (val & MPHY_SPCFC_STAT_DUPLEX) {
        xil_printf("FULL-DUPLEX ");
    } else {
        xil_printf("HALF-DUPLEX ");
    }

    if (val & MPHY_SPCFC_STAT_SPD_DUP_RSLVD) {
        xil_printf("SPD_DPLX_RSLVD ");
    } else {
        xil_printf("SPD_DPLX_NOT_RSLVD ");
    }

    if (val & MPHY_SPCFC_STAT_MDIX) { 
        xil_printf("MDIX ");
    } else {
        xil_printf("MDI ");
    }

    xil_printf("\n\r");
}

