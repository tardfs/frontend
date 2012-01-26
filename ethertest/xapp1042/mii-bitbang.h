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
* Filename:     mii-bitbang.h
*
* Description:
* Define prototypes for use with mii-bitbang.c
*
*
* MODIFICATION HISTORY:
*
* Ver    Who   Date     Changes
* ------ ----- -------- -----------------------------------------------------
* 1.00.a bhill 3/6/08   Initial release
*
*
* $Id: mii-bitbang.h,v 1.1 2007/11/14 22:37:42 bhill Exp $
******************************************************************************/

#ifndef _MII_BITBANG_H_
#define _MII_BITBANG_H_

/***************************** Include Files *********************************/
#include "xgpio.h"

/************************** Function Prototypes ******************************/
void    MiiGpio_PhyRead(XGpio *mii_gpio, u32 PhyAddress, u32 RegisterNum,
                        u16 *PhyDataPtr);
void    MiiGpio_PhyWrite(XGpio *mii_gpio, u32 PhyAddress, u32 RegisterNum,
                         u16 PhyData);
XStatus MiiGpio_Init(XGpio *mii_gpio);

#endif
