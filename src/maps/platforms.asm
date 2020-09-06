* = * "Platforms"
PLATFORMS: {
	.label MAX_PLATFORMS = 8
	
	COLOR_ORIGIN_LSB:
		.fill MAX_PLATFORMS, 0	
	COLOR_ORIGIN_MSB:
		.fill MAX_PLATFORMS, 0
	COLOR_ORIGIN_LSB_L:
		.fill MAX_PLATFORMS, 0	
	COLOR_ORIGIN_MSB_L:
		.fill MAX_PLATFORMS, 0	
	COLOR_ORIGIN_LSB_R:
		.fill MAX_PLATFORMS, 0	
	COLOR_ORIGIN_MSB_R:
		.fill MAX_PLATFORMS, 0	

	ORIGINAL_COLOR:
		.fill MAX_PLATFORMS, 0
	NEW_COLOR:
		.fill MAX_PLATFORMS, 0
	NEXT_COLOR_INDEX:
		.byte $00

	AddNewColorOrigin:{
			//A = LSB
			//Y = MSB
			//x = Projectile index	
			// .break
			stx PLATFORM_TEMP //X = DO NOT BASH
			pha
			txa 
			lsr
			tax 
			lda PLAYER.PlayerColors, x
			clc
			adc #$08
			// lda PROJECTILES.Player_Projectile_Color, x

			ldx NEXT_COLOR_INDEX
			sta NEW_COLOR, x 
			pla
			sta COLOR_ORIGIN_LSB, x 
			sta COLOR_ORIGIN_LSB_L, x 
			sta COLOR_ORIGIN_LSB_R, x 
			tya 
			sta COLOR_ORIGIN_MSB, x
			sta COLOR_ORIGIN_MSB_L, x
			sta COLOR_ORIGIN_MSB_R, x

	
			lda COLOR_ORIGIN_LSB, x
			sta PLATFORM_LOOKUP + 0
			lda COLOR_ORIGIN_MSB, x
			sta PLATFORM_LOOKUP + 1
			ldy #$00
			lda (PLATFORM_LOOKUP), y
			and #$0f
			cmp #$0c
			bne !+
			lda #$00
			sta COLOR_ORIGIN_MSB, x
			rts
		!:
			sta ORIGINAL_COLOR, x



			inx 
			cpx #MAX_PLATFORMS
			bne !+
			ldx #$00
		!:
			stx NEXT_COLOR_INDEX

			ldx PLATFORM_TEMP
			rts
	}



	UpdateColorOrigins: {
			ldx #MAX_PLATFORMS - 1


		!Loop:
			lda COLOR_ORIGIN_LSB, x
			sta PLATFORM_LOOKUP + 0
			sta PLATFORM_CHAR_LOOKUP + 0

			lda COLOR_ORIGIN_MSB, x
			sta PLATFORM_LOOKUP + 1
			sec
			sbc #[$d8 - [>SCREEN_RAM]]
			sta PLATFORM_CHAR_LOOKUP + 1


			bne !+
			beq !Skip+
		!:

			jsr FillPlatform

		!Skip:
			dex
			bpl !Loop-
			rts
	}



	FillPlatformToggle:
			.byte $00
	FillPlatform: {
			lda #$00
			sta PLATFORM_COMPLETE

			//left
		!Loop:
			ldy #$00
			tya 
			pha 
			lda (PLATFORM_CHAR_LOOKUP), y
			tay
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_COLORABLE
			bne !skip+
			inc PLATFORM_COMPLETE
			pla
			jmp !DoneLeft+
		!skip:
			pla
			tay


			lda (PLATFORM_LOOKUP), y
			and #$0f
			cmp NEW_COLOR, x
			bne !FoundNewColor+

			lda PLATFORM_LOOKUP + 0
			sec
			sbc #$01
			sta PLATFORM_LOOKUP + 0
			sta PLATFORM_CHAR_LOOKUP + 0
			lda PLATFORM_LOOKUP + 1
			sbc #$00
			sta PLATFORM_LOOKUP + 1
			sec
			sbc #[$d8 - [>SCREEN_RAM]]
			sta PLATFORM_CHAR_LOOKUP + 1			
			jmp !Loop-

		!FoundNewColor:
			cmp ORIGINAL_COLOR, x
			bne !LeftComplete+

			ldy #$00
			lda NEW_COLOR,x
			sta (PLATFORM_LOOKUP), y
			:playSFX(SOUND.FloorColorChange)
			
			jmp !DoneLeft+
		!LeftComplete:
			inc PLATFORM_COMPLETE
		!DoneLeft:


			//right
			ldy #$01
		!Loop:
			tya 
			pha 
			lda (PLATFORM_CHAR_LOOKUP), y
			tay
			lda CHAR_COLORS, y
			and #UTILS.COLLISION_COLORABLE
			bne !skip+
			inc PLATFORM_COMPLETE
			pla
			jmp !DoneRight+
		!skip:
			pla
			tay

			lda (PLATFORM_LOOKUP), y
			and #$0f
			cmp NEW_COLOR, x
			bne !FoundNewColor+
			iny
			bne !Loop-
		!FoundNewColor:
			cmp ORIGINAL_COLOR, x
			bne !RightComplete+

			lda NEW_COLOR,x
			sta (PLATFORM_LOOKUP), y
			:playSFX(SOUND.FloorColorChange)
			jmp !DoneRight+
		!RightComplete:
			inc PLATFORM_COMPLETE
		!DoneRight:	

			lda PLATFORM_COMPLETE
			cmp #$02
			bcc !+

			//Turn off update
			lda #$00
			sta COLOR_ORIGIN_MSB, x
		!:
			rts

	}
}