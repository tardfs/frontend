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
* Filename:     marvell_88e1111.h
*
* Description:
* Prototypes and definitions for use with marvell_88e1111.c
*
*
* MODIFICATION HISTORY:
*
* Ver    Who   Date     Changes
* ------ ----- -------- -----------------------------------------------------
* 1.00.a bhill 3/6/08   Initial release
*
*
* $Id: marvell_88e1111.h,v 1.1 2007/11/14 22:37:42 bhill Exp $
******************************************************************************/
#ifndef _MARVELL_88E1111_H_
#define _MARVELL_88E1111_H_

/**************************** Type Definitions *******************************/
typedef void PhyWrite_t (void *phy_inst,
                         u32 PhyAddress,
                         u32 RegisterNum,
                         u16 PhyData);
typedef void PhyRead_t  (void *phy_inst,
                         u32 PhyAddress,
                         u32 RegisterNum,
                         u16 *PhyDataPtr);

/************************** Function Prototypes ******************************/
void marvell_phy_setvectors(PhyRead_t *read_fp, PhyWrite_t *write_fp);
int  marvell_phy_link_status(void *phy_inst, u32 PhyAddress);
void marvell_phy_display_status(void *phy_inst, u32 PhyAddress);
void marvell_phy_set_1000mb_autoneg(void *phy_inst, u32 PhyAddress, int Enable);
int  marvell_phy_detected(void *phy_inst, u32 PhyAddress);

/************************** Constant Definitions *****************************/
#define MPHY_CONTROL_REG           0
#define MPHY_CONTROL_LOOPBACK      (1 << 14)
#define MPHY_CONTROL_AUTONEG       (1 << 12)
#define MPHY_CONTROL_SPD_SEL_LSB   (1 << 13)
#define MPHY_CONTROL_SPD_SEL_MSB   (1 <<  6)
#define MPHY_CONTROL_SPD_SEL_RSVD  3
#define MPHY_CONTROL_SPD_SEL_1000  2
#define MPHY_CONTROL_SPD_SEL_100   1
#define MPHY_CONTROL_SPD_SEL_10    0
#define MPHY_CONTROL_RSTRT_AUTONEG (1 <<  9)
#define MPHY_CONTROL_DUPLEX        (1 <<  8)

#define MPHY_STATUS_REG            1
#define MPHY_STATUS_LINK           (1 <<  2)

#define MPHY_ID0_REG               2
#define MPHY_ID0_MARVELL_OUI       0x0141

#define MPHY_ID1_REG               3

#define MPHY_AUTONEG_ADV_REG       4
#define MPHY_AUTONEG_ADV_100TX_FD (1 <<  8)
#define MPHY_AUTONEG_ADV_100TX_HD (1 <<  7)
#define MPHY_AUTONEG_ADV_10TX_FD  (1 <<  6)
#define MPHY_AUTONEG_ADV_10TX_HD  (1 <<  5)

#define MPHY_1000BT_CONTROL_REG    9
#define MPHY_1000BT_CONTROL_ADV_1000BT_FD  (1 << 9)
#define MPHY_1000BT_CONTROL_ADV_1000BT_HD  (1 << 8)

#define MPHY_SPCFC_STATUS_REG         17
#define MPHY_SPCFC_STAT_SPD_SHIFT     14
#define MPHY_SPCFC_STAT_SPD_RESVD     3
#define MPHY_SPCFC_STAT_SPD_1000      2
#define MPHY_SPCFC_STAT_SPD_100       1
#define MPHY_SPCFC_STAT_SPD_10        0
#define MPHY_SPCFC_STAT_DUPLEX        (1 << 13)
#define MPHY_SPCFC_STAT_SPD_DUP_RSLVD (1 << 11)
#define MPHY_SPCFC_STAT_LINK_RT       (1 << 10)
#define MPHY_SPCFC_STAT_MDIX          (1 <<  6)

#endif
