.macro PositionEnemy() {
		.label INDEX = TEMP8
		.label STOREY = TEMP7

		sty STOREY
		stx INDEX

		lda ENEMIES.EnemyFrame, x
		sta SPRITE_POINTERS + 3, x

		txa
		tay
		asl
		tax
		lda ENEMIES.EnemyPosition_X1, y
		sta VIC.SPRITE_0_X + [3 * 2], x
		lda ENEMIES.EnemyPosition_Y1, y
		sta VIC.SPRITE_0_Y + [3 * 2], x
		ldx INDEX
		ldy ENEMIES.EnemyPosition_X2, x
		inx
		inx
		inx
		lda $d010
		and TABLES.InvPowerOfTwo, x
		cpy #$00
		beq !+
		ora TABLES.PowerOfTwo, x
	!:
		sta $d010
		dex
		dex
		dex
		ldy STOREY
		ldx INDEX
}

.macro UpdatePosition(xpos, ypos) {
	.if(xpos > 0) {
		clc
		lda ENEMIES.EnemyPosition_X0, x
		adc #<xpos
		sta ENEMIES.EnemyPosition_X0, x 
		lda ENEMIES.EnemyPosition_X1, x
		adc #>xpos
		sta ENEMIES.EnemyPosition_X1, x 
		lda ENEMIES.EnemyPosition_X2, x
		adc #$00
		sta ENEMIES.EnemyPosition_X2, x 
	}
	.if(xpos < 0) {
		.eval xpos = xpos * -1
		sec
		lda ENEMIES.EnemyPosition_X0, x
		sbc #<xpos
		sta ENEMIES.EnemyPosition_X0, x 
		lda ENEMIES.EnemyPosition_X1, x
		sbc #>xpos
		sta ENEMIES.EnemyPosition_X1, x 
		lda ENEMIES.EnemyPosition_X2, x
		sbc #$00
		sta ENEMIES.EnemyPosition_X2, x 
	}	

	.if(ypos > 0) {
		clc
		lda ENEMIES.EnemyPosition_Y0, x
		adc #<ypos
		sta ENEMIES.EnemyPosition_Y0, x 
		lda ENEMIES.EnemyPosition_Y1, x
		adc #>ypos
		sta ENEMIES.EnemyPosition_Y1, x 
	} 
	.if(ypos < 0) {
		.eval ypos = ypos * -1
		sec
		lda ENEMIES.EnemyPosition_Y0, x
		sbc #<ypos
		sta ENEMIES.EnemyPosition_Y0, x 
		lda ENEMIES.EnemyPosition_Y1, x
		sbc #>ypos
		sta ENEMIES.EnemyPosition_Y1, x 
	}	
}

.macro setEnemyFrame(frame) {
	.if(frame != 0) {
		lda #frame
	}
	sta ENEMIES.EnemyFrame, x
}

.macro setStaticMemory(index, value) {
	.if(value != null) {
		lda #value
	}
	sta ENEMIES.EnemyStaticMemory + index * ENEMIES.MAX_ENEMIES, x
}


.macro getStaticMemory(index) {
	lda ENEMIES.EnemyStaticMemory + index * ENEMIES.MAX_ENEMIES, x
}



.macro getEnemyCollisions(xoffset, yoffset) {
		.label TEMP = TEMP8
		lda #xoffset
		ldy #yoffset
		jsr ENEMIES.GetCollisionPoint
		stx TEMP
		tax
		jsr UTILS.GetCharacterAt
		ldx TEMP
}

.macro doFall(xcheck, ycheck) {
		:getEnemyCollisions(xcheck, ycheck)
		tay
		lda CHAR_COLORS, y
		and #PLAYER.COLLISION_SOLID
		beq !Fall+

		lda ENEMIES.EnemyState, x
		and #[255 - ENEMIES.STATE_FALL]
		sta ENEMIES.EnemyState, x
		jmp !NoFall+

	!Fall:
		lda ENEMIES.EnemyState, x
		and #ENEMIES.STATE_FALL
		bne !+
		ora #ENEMIES.STATE_FALL
		sta ENEMIES.EnemyState, x
		lda #[TABLES.__JumpAndFallTable -  TABLES.JumpAndFallTable - 1]
		sta ENEMIES.EnemyJumpFallIndex, x

	!:
		lda ENEMIES.EnemyJumpFallIndex, x
		tay 
		lda TABLES.JumpAndFallTable, y
		clc
		adc ENEMIES.EnemyPosition_Y1, x
		sta ENEMIES.EnemyPosition_Y1, x 

		dec ENEMIES.EnemyJumpFallIndex, x
		bpl !+
		lda #$00
		sta ENEMIES.EnemyJumpFallIndex, x 
	!:
	!NoFall:
}