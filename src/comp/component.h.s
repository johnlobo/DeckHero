;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of 1to1 Soccer: An Amstrad CPC Game
;;  Copyright (C) 2020 Utopia (@UtopiaRetroDev)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see http://www.gnu.org/licenses/.
;;-------------------------------------------------------------------------------

.module Component

.include "common.h.s"


;;===============================================================================
;; COMPONENT DEFINITION MACRO
;;===============================================================================


.macro DefineComponentArrayStructure_Size _Tname, _N, _ComponentSize
      _Tname'_num::     .db 0
      _Tname'_pend::    .dw _Tname'_array 
      _Tname'_selected::.db 0
      _Tname'_X_start:: .db 40
      _Tname'_array::
            .ds _N * _ComponentSize
.endm

;;===============================================================================
;; DATA ARRAY SCTRUCTURE CREATION
;;===============================================================================
BeginStruct a
Field a, count , 1
Field a, pend , 2
Field a, selected , 1
Field a, X_start , 1
Field a, array , 1
EndStruct a

;;===============================================================================
;; POINTER TO CARD DEFINITION MACRO
;;===============================================================================
.macro DefineP2C _status, _pointer
    .db _status
    .dw _pointer
.endm

;;===============================================================================
;; POINTER TO CARD SCTRUCTURE CREATION
;;===============================================================================
BeginStruct p2c
Field p2c, status , 1
Field p2c, p , 2
EndStruct p2c