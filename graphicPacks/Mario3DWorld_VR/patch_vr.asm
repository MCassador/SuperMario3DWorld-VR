[Mario3DWorld_VR_R3_EU_v0]
moduleMatches = 0xD2308838
.origin = codecave
; Stereo render flow: two drawings from one calculated simulation state.
rrFlowHeader:
.int 0x4354464C
.int 1
rrEnabled:
.int 1
rrExtraDraws:
.int 0
rrSkipped:
.int 0
rrMarkerMagic:
.int 0x43544D31
rrMarkerAck:
.int 0
rrEye:
.int 0
rrSlot:
.int 0
rrCopyCalls:
.int 0
rrCopyBuffer:
.int 0
rrCopyTarget:
.int 0
rrEmitCount:
.int 0
rrValueTV:
.int 0x3D000000
rrValueDRC:
.int 0x3E000000
rrValueA:
.int 0x3DFCD6EA
rrValueB:
.int 0x3F7CD6EA
rrValueZero:
.int 0
rrValueOne:
.int 0x3F800000
; The HUD protocol marker: cemuvr_layer.dll looks for it within 0x4000 bytes of rrFlowHeader and
; acknowledges it in the next word, so it must stay here at the start (the codecave grew past that
; once, and the HUD stayed inside both eye pictures - doubled - instead of its own layer).
rrHudWorldMagic:
.int 0x48554132
rrHudWorldAck:
.int 0
0x024DB32C = rrAfterSecondDraw:
0x024DB93C = rrPresent:
0x024DB728 = rrDraw:
0x024DBA84 = rrRecord:
rrSecondDraw:
mflr r0
stwu r1, -0x20(r1)
stw r0, 0x24(r1)
lis r12, rrEnabled@ha
addi r12, r12, rrEnabled@l
lwz r11, 0(r12)
cmpwi r11, 1
bne rrSkip
lwz r11, 0x74(r29)
andi. r11, r11, 1
bne rrSkip
; Display-list preparation has to exist before an additional draw is possible.
lbz r11, 0x380(r29)
cmpwi r11, 0
beq rrSkip
lwz r11, 0x388(r29)
cmpwi r11, 0
blt rrSkip
; The original draw consumed the previous prepared list. Finish/present it.
mr r3, r29
bl import.gx2.GX2DrawDone
; Draw the just-prepared list; procDraw flips the list-buffer index itself.
mr r3, r29
bl rrDraw
; Conservative GPU barrier between eye renders.
bl import.gx2.GX2DrawDone
; Prepare the other list from the same calculated state, without another calc.
lis r12, rrEye@ha
addi r12, r12, rrEye@l
li r11, 1
stw r11, 0(r12)
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
li r11, 1
stw r11, 0(r12)
mr r3, r29
bl rrRecord
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
li r11, 0
stw r11, 0(r12)
lis r12, rrExtraDraws@ha
addi r12, r12, rrExtraDraws@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
b rrFinish
rrSkip:
lis r12, rrSkipped@ha
addi r12, r12, rrSkipped@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
rrFinish:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
lwz r5, 0x24(r29)
b rrAfterSecondDraw
0x024DB328 = ba rrSecondDraw

0x024DB304 = rrAfterBeforeCalc:
rrBeforeCalc:
lis r12, mrCullCount@ha
li r11, 0
stw r11, mrCullCount@l(r12)
lis r12, mrCullEpoch@ha
lwz r11, mrCullEpoch@l(r12)
addi r11, r11, 1
stw r11, mrCullEpoch@l(r12)
; Complete the submitted second eye BEFORE game calc reuses effect data.
stwu r1, -0x20(r1)
stw r0, 8(r1)
mflr r0
stw r0, 0x24(r1)
bl import.gx2.GX2DrawDone
lwz r0, 0x24(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0x20
lis r12, rrEye@ha
addi r12, r12, rrEye@l
li r11, 0
stw r11, 0(r12)
lwz r11, 4(r12)
addi r11, r11, 1
andi. r11, r11, 1
stw r11, 4(r12)
; Pose packet, published by the host; sequence is even when complete.
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
li r11, 0
stw r11, 0(r12)
lis r8, rrPoseHeader@ha
addi r8, r8, rrPoseHeader@l
lwz r7, 8(r8)
andi. r11, r7, 1
bne rrPoseLatchDone
cmpwi r7, 0
beq rrPoseLatchDone
lwz r11, 12(r8)
cmpwi r11, 1
bne rrPoseLatchDone
.int 0x7C2004AC ; lwsync
lwz r11, 24(r8)
stw r11, 4(r12)
lwz r11, 28(r8)
stw r11, 8(r12)
lwz r11, 32(r8)
stw r11, 12(r12)
lwz r11, 36(r8)
stw r11, 16(r12)
lwz r11, 40(r8)
stw r11, 20(r12)
lwz r11, 44(r8)
stw r11, 24(r12)
lwz r11, 48(r8)
stw r11, 28(r12)
lwz r11, 52(r8)
stw r11, 32(r12)
lwz r11, 56(r8)
stw r11, 36(r12)
lwz r11, 60(r8)
stw r11, 40(r12)
lwz r11, 64(r8)
stw r11, 44(r12)
lwz r11, 68(r8)
stw r11, 48(r12)
lwz r11, 72(r8)
stw r11, 52(r12)
lwz r11, 76(r8)
stw r11, 56(r12)
lwz r11, 80(r8)
stw r11, 60(r12)
lwz r11, 84(r8)
stw r11, 64(r12)
lwz r11, 88(r8)
stw r11, 68(r12)
lwz r11, 92(r8)
stw r11, 72(r12)
lwz r11, 96(r8)
stw r11, 76(r12)
lwz r11, 100(r8)
stw r11, 80(r12)
lwz r11, 104(r8)
stw r11, 84(r12)
lwz r11, 108(r8)
stw r11, 88(r12)
lwz r11, 112(r8)
stw r11, 92(r12)
lwz r11, 116(r8)
stw r11, 96(r12)
lwz r11, 120(r8)
stw r11, 100(r12)
lwz r11, 124(r8)
stw r11, 104(r12)
lwz r11, 128(r8)
stw r11, 108(r12)
lwz r11, 132(r8)
stw r11, 112(r12)
lwz r11, 136(r8)
stw r11, 116(r12)
lwz r11, 140(r8)
stw r11, 120(r12)
lwz r11, 144(r8)
stw r11, 124(r12)
lwz r11, 148(r8)
stw r11, 128(r12)
lwz r11, 152(r8)
stw r11, 132(r12)
lwz r11, 156(r8)
stw r11, 136(r12)
lwz r11, 160(r8)
stw r11, 140(r12)
lwz r11, 164(r8)
stw r11, 144(r12)
lwz r11, 168(r8)
stw r11, 148(r12)
lwz r11, 172(r8)
stw r11, 152(r12)
lwz r11, 176(r8)
stw r11, 156(r12)
lwz r11, 180(r8)
stw r11, 160(r12)
lwz r11, 184(r8)
stw r11, 164(r12)
lwz r11, 188(r8)
stw r11, 168(r12)
lwz r11, 192(r8)
stw r11, 172(r12)
lwz r11, 196(r8)
stw r11, 176(r12)
lwz r11, 200(r8)
stw r11, 180(r12)
lwz r11, 204(r8)
stw r11, 184(r12)
lwz r11, 208(r8)
stw r11, 188(r12)
lwz r11, 212(r8)
stw r11, 192(r12)
; The controllers, copied under the same sequence guard as the pose.
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lwz r11, 216(r8)
stw r11, 0(r10)
lwz r11, 220(r8)
stw r11, 4(r10)
lwz r11, 224(r8)
stw r11, 8(r10)
lwz r11, 228(r8)
stw r11, 12(r10)
lwz r11, 232(r8)
stw r11, 16(r10)
lwz r11, 236(r8)
stw r11, 20(r10)
lwz r11, 240(r8)
stw r11, 24(r10)
lwz r11, 244(r8)
stw r11, 28(r10)
lwz r11, 248(r8)
stw r11, 32(r10)
lwz r11, 252(r8)
stw r11, 36(r10)
lwz r11, 256(r8)
stw r11, 40(r10)
lwz r11, 260(r8)
stw r11, 44(r10)
lwz r11, 264(r8)
stw r11, 48(r10)
lwz r11, 268(r8)
stw r11, 52(r10)
lwz r11, 272(r8)
stw r11, 56(r10)
lwz r11, 276(r8)
stw r11, 60(r10)
lwz r11, 280(r8)
stw r11, 64(r10)
lwz r11, 284(r8)
stw r11, 68(r10)
lwz r11, 288(r8)
stw r11, 72(r10)
lwz r11, 292(r8)
stw r11, 76(r10)
lwz r11, 296(r8)
stw r11, 80(r10)
lwz r11, 300(r8)
stw r11, 84(r10)
lwz r11, 304(r8)
stw r11, 88(r10)
lwz r11, 308(r8)
stw r11, 92(r10)
lwz r11, 312(r8)
stw r11, 96(r10)
lwz r11, 316(r8)
stw r11, 100(r10)
lwz r11, 320(r8)
stw r11, 104(r10)
lwz r11, 324(r8)
stw r11, 108(r10)
lwz r11, 328(r8)
stw r11, 112(r10)
lwz r11, 332(r8)
stw r11, 116(r10)
lwz r11, 336(r8)
stw r11, 120(r10)
lwz r11, 340(r8)
stw r11, 124(r10)
lwz r11, 344(r8)
stw r11, 128(r10)
lwz r11, 348(r8)
stw r11, 132(r10)
lwz r11, 352(r8)
stw r11, 136(r10)
lwz r11, 356(r8)
stw r11, 140(r10)
lwz r11, 360(r8)
stw r11, 144(r10)
lwz r11, 364(r8)
stw r11, 148(r10)
lwz r11, 368(r8)
stw r11, 152(r10)
lwz r11, 372(r8)
stw r11, 156(r10)
.int 0x7C2004AC ; lwsync
lwz r11, 8(r8)
cmpw r7, r11
bne rrPoseLatchDone
stw r7, 0(r12)
rrPoseLatchDone:
; The camera switch off the right controller's stick click. This path never
; touches Cemu's input configuration, which is where the reported failures live.
lis r9, mtPad@ha
addi r9, r9, mtPad@l
lwz r7, 0(r9)
cmpwi r7, 0
beq mtPadDone
li r7, 0
lwz r10, 88(r9)
cmpwi r10, 0
beq mtPadStore
lwz r10, 140(r9)
li r11, 4
and r10, r10, r11
cmpwi r10, 0
beq mtPadStore
li r7, 1
mtPadStore:
lis r10, mtControl@ha
addi r10, r10, mtControl@l
lwz r11, 68(r10)
stw r7, 68(r10)
cmpwi r7, 0
beq mtPadDone
cmpw r7, r11
beq mtPadDone
; Same as the pad button: in first person, step the camera distance first and
; leave first person only after the last step.
lwz r7, 0(r10)
cmpwi r7, 1
bne mtPadFlipMode
lis r9, mtEyeBackCtl@ha
addi r9, r9, mtEyeBackCtl@l
lwz r7, 28(r10)
cmpwi r7, 1
bne mtPadLeave
lwz r11, 8(r9)
addi r11, r11, 1
cmpwi r11, 2
bge mtPadLeave
stw r11, 8(r9)
mulli r12, r11, 4
add r12, r12, r9
lwz r7, 12(r12)
lis r12, mtEyeBack@ha
stw r7, mtEyeBack@l(r12)
b mtPadDone
mtPadLeave:
li r11, 0
stw r11, 8(r9)
lwz r7, 12(r9)
lis r12, mtEyeBack@ha
stw r7, mtEyeBack@l(r12)
mtPadFlipMode:
lwz r7, 0(r10)
cmpwi r7, 0
li r7, 1
beq mtPadFlip
li r7, 0
mtPadFlip:
stw r7, 0(r10)
lwz r7, 8(r10)
addi r7, r7, 1
stw r7, 8(r10)
lis r10, mrLookCos@ha
addi r10, r10, mrLookCos@l
lis r7, 0x3F80
stw r7, 0(r10)
li r7, 0
stw r7, 4(r10)
stw r7, 8(r10)
mtPadDone:
lis r8, mtControl@ha
addi r8, r8, mtControl@l
lis r11, rrSlot@ha
lwz r11, rrSlot@l(r11)
mulli r11, r11, 8
add r11, r11, r8
lwz r7, 0(r8)
stw r7, 32(r11)
lwz r7, 8(r8)
stw r7, 36(r11)
lis r11, rrDioramaDistance@ha
lis r7, 0x3F26
ori r7, r7, 0x6666
stw r7, rrDioramaDistance@l(r11)
lis r11, rrDioramaAdvance@ha
lis r7, 0x3EB3
ori r7, r7, 0x3333
stw r7, rrDioramaAdvance@l(r11)
lis r12, mrSceneClass@ha
li r11, 0
stw r11, mrSceneClass@l(r12)
lis r12, tsScene@ha
stw r11, tsScene@l(r12)
lis r9, rrSlot@ha
addi r9, r9, rrSlot@l
lwz r10, 0(r9)
mulli r10, r10, 8
lis r9, rrMenuCameraUsed@ha
addi r9, r9, rrMenuCameraUsed@l
add r9, r9, r10
li r10, 0
stw r10, 0(r9)
stw r10, 4(r9)
mr r3, r29
b rrAfterBeforeCalc
0x024DB300 = ba rrBeforeCalc

rrCopyMarker:
mflr r0
stwu r1, -0x20(r1)
stw r0, 0x24(r1)
stw r3, 0x1C(r1)
stw r4, 0x18(r1)
lis r12, rrCopyCalls@ha
addi r12, r12, rrCopyCalls@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
stw r3, 4(r12)
stw r4, 8(r12)
bl import.gx2.GX2CopyColorBufferToScanBuffer
; Only emit protocol clear commands after this process's core acknowledges support.
lis r12, rrMarkerAck@ha
addi r12, r12, rrMarkerAck@l
lwz r11, 0(r12)
lis r10, 0x4354
addi r10, r10, 0x4D31
cmpw r11, r10
bne rrCopyExit
lwz r4, 0x18(r1)
cmpwi r4, 1
beq rrCopyTV
cmpwi r4, 4
bne rrCopyExit
lis r12, rrValueDRC@ha
addi r12, r12, rrValueDRC@l
lfs f1, 0(r12)
b rrCopyEye
rrCopyTV:
lis r12, rrValueTV@ha
addi r12, r12, rrValueTV@l
lfs f1, 0(r12)
rrCopyEye:
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r11, 0(r12)
cmpwi r11, 0
lis r12, rrValueA@ha
addi r12, r12, rrValueA@l
bne rrCopyRight
lfs f2, 0(r12)
lfs f3, 4(r12)
b rrCopySlot
rrCopyRight:
lfs f3, 0(r12)
lfs f2, 4(r12)
rrCopySlot:
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
cmpwi r11, 0
lis r12, rrValueZero@ha
addi r12, r12, rrValueZero@l
bne rrCopySlotOne
lfs f4, 0(r12)
b rrEmitMarker
rrCopySlotOne:
lfs f4, 4(r12)
rrEmitMarker:
lis r12, rrEmitCount@ha
addi r12, r12, rrEmitCount@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
; Preserve the ordinary eye marker across the metadata clear call.
stwu r1, -0x20(r1)
stfs f1, 8(r1)
stfs f2, 12(r1)
stfs f3, 16(r1)
stfs f4, 20(r1)
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lfs f3, 164(r12)
lfs f4, 168(r12)
lwz r11, 0(r12)
cmpwi r11, 0
beq rrPoseMarkerInvalid
mr r10, r11
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r11, 4(r12)
lwz r12, 0(r12)
mulli r11, r11, 2
add r11, r11, r12
mulli r11, r11, 4
lis r12, rrProjectionPoseSequence@ha
addi r12, r12, rrProjectionPoseSequence@l
add r12, r12, r11
lwz r11, 0(r12)
cmpw r10, r11
beq rrPoseMarkerValid
rrPoseMarkerInvalid:
lis r12, rrValueZero@ha
addi r12, r12, rrValueZero@l
lfs f3, 0(r12)
lfs f4, 0(r12)
rrPoseMarkerValid:
lis r12, rrPoseMarkerMagic@ha
addi r12, r12, rrPoseMarkerMagic@l
lfs f1, 0(r12)
lfs f2, 4(r12)
rrMenuMetadataSelect:
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r11, 0(r12)
lwz r12, 4(r12)
mulli r12, r12, 2
add r11, r11, r12
mulli r11, r11, 4
lis r12, rrMenuCameraUsed@ha
addi r12, r12, rrMenuCameraUsed@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 0
bne rrMenuMetadataDone
lis r12, rrMenuMetadataMagic@ha
addi r12, r12, rrMenuMetadataMagic@l
lfs f1, 0(r12)
rrMenuMetadataDone:
lwz r3, 0x3C(r1)
bl import.gx2.GX2ClearColor
lfs f1, 8(r1)
lfs f2, 12(r1)
lfs f3, 16(r1)
lfs f4, 20(r1)
addi r1, r1, 0x20
lwz r3, 0x1C(r1)
bl import.gx2.GX2ClearColor
rrCopyExit:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
blr

rrCameraHeader:
.int 0x43544341
.int 1
rrCameraEnabled:
.int 1
rrCameraCalls:
.int 0
rrCameraLeft:
.int 0
rrCameraRight:
.int 0
rrCameraSource:
.int 0
rrCameraCaller:
.int 0
rrCameraOriginal:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrCamera0:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrCamera1:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrCamera2:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrCamera3:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrCameraFactorLeft:
.int 0x3CA3D70A
rrCameraFactorRight:
.int 0xBCA3D70A
rrCameraMinusOne:
.int 0xBF800000
rrCameraHook:
lis r9, tsStats@ha
addi r9, r9, tsStats@l
lwz r11, 0(r9)
addi r11, r11, 1
stw r11, 0(r9)
lis r9, tsScene@ha
lwz r9, tsScene@l(r9)
lis r12, 0x1000
cmplw r9, r12
blt tsCameraContinue
lis r12, 0x5000
cmplw r9, r12
bge tsCameraContinue
andi. r12, r9, 3
bne tsCameraContinue
lwz r11, 0(r9)
lis r12, tsStats@ha
addi r12, r12, tsStats@l
stw r11, 8(r12)
lis r12, 0x1032
ori r12, r12, 0x8FEC
cmpw r11, r12
bne tsCameraContinue
; Native state getter 022E3F28 -> scene+4. Native query 02440DD0
; prefers pending state (+8) to current (+4), catching A before iris starts.
lwz r11, 4(r9)
lis r12, 0x1000
cmplw r11, r12
blt tsCheckWipe
lis r12, 0x5000
cmplw r11, r12
bge tsCheckWipe
andi. r12, r11, 3
bne tsCheckWipe
lwz r12, 8(r11)
cmpwi r12, 0
bne tsStateReady
lwz r12, 4(r11)
tsStateReady:
lis r11, tsStats@ha
addi r11, r11, tsStats@l
stw r12, 12(r11)
lis r11, 0x104E
ori r11, r11, 0x6228
cmpw r12, r11
beq tsUseSurface
lis r11, 0x104E
ori r11, r11, 0x622C
cmpw r12, r11
beq tsUseSurface
lis r11, 0x104E
ori r11, r11, 0x6230
cmpw r12, r11
beq tsUseSurface
lis r11, 0x104E
ori r11, r11, 0x6234
cmpw r12, r11
beq tsUseSurface
lis r11, 0x104E
ori r11, r11, 0x6238
cmpw r12, r11
beq tsUseSurface
lis r11, 0x104E
ori r11, r11, 0x623C
cmpw r12, r11
beq tsUseSurface
lis r11, 0x104E
ori r11, r11, 0x6244
cmpw r12, r11
beq tsUseSurface
tsCheckWipe:
; Exact TitleScene WipeCircle owner (constructor 022E2898/28A0).
; Native title code itself checks actor+4C at 022E35B8 and 022E3C0C.
lwz r11, 0xA4(r9)
lis r12, 0x1000
cmplw r11, r12
blt tsCameraContinue
lis r12, 0x5000
cmplw r11, r12
bge tsCameraContinue
andi. r12, r11, 3
bne tsCameraContinue
lwz r9, 0(r11)
lis r12, 0x1037
ori r12, r12, 0x3F14
cmpw r9, r12
bne tsCameraContinue
lbz r11, 0x4C(r11)
cmpwi r11, 0
beq tsCameraContinue
tsUseSurface:
lis r9, tsStats@ha
addi r9, r9, tsStats@l
lwz r11, 4(r9)
addi r11, r11, 1
stw r11, 4(r9)
b rrCameraExit
tsCameraContinue:
; The original epilogue restored LR and SP. Only ABI-volatile registers follow.
cmpwi r3, 0
beq rrCameraExit
mflr r10
lis r12, rrCameraEnabled@ha
addi r12, r12, rrCameraEnabled@l
lwz r11, 0(r12)
cmpwi r11, 1
bne rrCameraExit
stw r3, 16(r12)
stw r10, 20(r12)
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
lis r9, rrEye@ha
addi r9, r9, rrEye@l
lwz r10, 0(r9)
lwz r9, 4(r9)
mulli r9, r9, 2
add r9, r9, r10
mulli r9, r9, 4
lis r10, rrMenuCameraUsed@ha
addi r10, r10, rrMenuCameraUsed@l
add r9, r9, r10
li r10, 1
stw r10, 0(r9)
lis r9, rrCameraOriginal@ha
addi r9, r9, rrCameraOriginal@l
lwz r11, 0(r3)
stw r11, 0(r9)
lwz r11, 4(r3)
stw r11, 4(r9)
lwz r11, 8(r3)
stw r11, 8(r9)
lwz r11, 12(r3)
stw r11, 12(r9)
lwz r11, 16(r3)
stw r11, 16(r9)
lwz r11, 20(r3)
stw r11, 20(r9)
lwz r11, 24(r3)
stw r11, 24(r9)
lwz r11, 28(r3)
stw r11, 28(r9)
lwz r11, 32(r3)
stw r11, 32(r9)
lwz r11, 36(r3)
stw r11, 36(r9)
lwz r11, 40(r3)
stw r11, 40(r9)
lwz r11, 44(r3)
stw r11, 44(r9)
lwz r11, 48(r3)
stw r11, 48(r9)
lwz r11, 52(r3)
stw r11, 52(r9)
lwz r11, 56(r3)
stw r11, 56(r9)
lwz r11, 60(r3)
stw r11, 60(r9)
lwz r11, 64(r3)
stw r11, 64(r9)
lwz r11, 68(r3)
stw r11, 68(r9)
lwz r11, 72(r3)
stw r11, 72(r9)
lwz r11, 76(r3)
stw r11, 76(r9)
lwz r11, 80(r3)
stw r11, 80(r9)
lwz r11, 84(r3)
stw r11, 84(r9)
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r10, 0(r12)
lwz r11, 4(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 88
lis r9, rrCamera0@ha
addi r9, r9, rrCamera0@l
add r9, r9, r11
lwz r11, 0(r3)
stw r11, 0(r9)
lwz r11, 4(r3)
stw r11, 4(r9)
lwz r11, 8(r3)
stw r11, 8(r9)
lwz r11, 12(r3)
stw r11, 12(r9)
lwz r11, 16(r3)
stw r11, 16(r9)
lwz r11, 20(r3)
stw r11, 20(r9)
lwz r11, 24(r3)
stw r11, 24(r9)
lwz r11, 28(r3)
stw r11, 28(r9)
lwz r11, 32(r3)
stw r11, 32(r9)
lwz r11, 36(r3)
stw r11, 36(r9)
lwz r11, 40(r3)
stw r11, 40(r9)
lwz r11, 44(r3)
stw r11, 44(r9)
lwz r11, 48(r3)
stw r11, 48(r9)
lwz r11, 52(r3)
stw r11, 52(r9)
lwz r11, 56(r3)
stw r11, 56(r9)
lwz r11, 60(r3)
stw r11, 60(r9)
lwz r11, 64(r3)
stw r11, 64(r9)
lwz r11, 68(r3)
stw r11, 68(r9)
lwz r11, 72(r3)
stw r11, 72(r9)
lwz r11, 76(r3)
stw r11, 76(r9)
lwz r11, 80(r3)
stw r11, 80(r9)
lwz r11, 84(r3)
stw r11, 84(r9)
lis r12, rrCameraLeft@ha
addi r12, r12, rrCameraLeft@l
cmpwi r10, 0
beq rrCameraChooseLeft
addi r12, r12, 4
rrCameraChooseLeft:
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 0
beq rrPoseFallback
lis r8, rrValueOne@ha
addi r8, r8, rrValueOne@l
lfs f3, 0(r8)
; Same diagnostic eye numbering: eye0 uses physical right, eye1 left.
addi r12, r12, 4
cmpwi r10, 1
beq mtEyeSelected
addi r12, r12, 48
mtEyeSelected:
lis r8, mtControl@ha
addi r8, r8, mtControl@l
lis r11, rrSlot@ha
lwz r11, rrSlot@l(r11)
mulli r11, r11, 8
add r11, r11, r8
lwz r7, 32(r11)
stw r7, 28(r8)
lwz r7, 36(r11)
lwz r0, 12(r8)
cmpw r7, r0
beq mtAnchorReady
stw r7, 12(r8)
addi r11, r12, 48
cmpwi r10, 1
beq mtOtherEyeReady
addi r11, r12, -48
mtOtherEyeReady:
lfs f1, 12(r12)
lfs f2, 12(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 0(r12)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 28(r12)
lfs f2, 28(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 16(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 44(r12)
lfs f2, 44(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 32(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r8)
lfs f1, 12(r12)
lfs f2, 12(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 4(r12)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 28(r12)
lfs f2, 28(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 20(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 44(r12)
lfs f2, 44(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 36(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r8)
lfs f1, 12(r12)
lfs f2, 12(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 8(r12)
fmuls f1, f1, f2
fmr f0, f1
lfs f1, 28(r12)
lfs f2, 28(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 24(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 44(r12)
lfs f2, 44(r11)
fadds f1, f1, f2
lfs f2, 48(r8)
fmuls f1, f1, f2
lfs f2, 40(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r8)
mtAnchorReady:
lwz r0, 28(r8)
cmpwi r0, 1
bne mtUseDiorama
lis r11, mrSceneClass@ha
lwz r11, mrSceneClass@l(r11)
lis r7, 0x1032
ori r7, r7, 0x86DC
cmpw r11, r7
bne mtUseDiorama
lwz r11, 580(r3)
lis r7, 0x1000
cmplw r11, r7
blt mtUseDiorama
lis r7, 0x5000
cmplw r11, r7
bge mtUseDiorama
andi. r0, r11, 3
bne mtUseDiorama
lwz r0, 0(r11)
lis r7, 0x1031
ori r7, r7, 0x9EF4
cmpw r0, r7
bne mtUseDiorama
lis r7, mtCine@ha
li r0, 0
stw r0, mtCine@l(r7)
lis r7, mrEyeTarget@ha
addi r7, r7, mrEyeTarget@l
lfs f0, 1976(r11)
stfs f0, 0(r7)
; the eye height: the standing one (mrEyeTarget+12), or inside a clear pipe the pipe's (mtPipeEye+4); the height in use (mtPipeEye+8) eases toward it by mtPipeEye+12 per step
lfs f1, 12(r7)
lis r7, mtPipeEye@ha
addi r7, r7, mtPipeEye@l
lwz r0, 0(r7)
cmpwi r0, 0
beq mtPipeEyeStand
lwz r0, 4(r7)
cmpwi r0, 0
ble mtPipeEyeStand
lfs f1, 4(r7)
mtPipeEyeStand:
lwz r0, 16(r7)
cmpwi r0, 0
beq mtPipeEyeLow
lwz r0, 0(r7)
cmpwi r0, 0
bne mtPipeEyeLow
lfs f2, 20(r7)
fadds f1, f1, f2
mtPipeEyeLow:
; the Bill Box suit worn (mtPipeEye+24 counts down once per step, set to 3 by mtHideBox): the eyes move by mtPipeEye+28
; (no addi r0, r0, n here: with rA = r0 that is li r0, n)
lwz r0, 24(r7)
cmpwi r0, 0
ble mtPipeEyeBoxNo
cmpwi r0, 3
bge mtPipeEyeBox3
cmpwi r0, 2
bge mtPipeEyeBox2
li r0, 0
b mtPipeEyeBoxSt
mtPipeEyeBox2:
li r0, 1
b mtPipeEyeBoxSt
mtPipeEyeBox3:
li r0, 2
mtPipeEyeBoxSt:
stw r0, 24(r7)
lfs f2, 28(r7)
fadds f1, f1, f2
mtPipeEyeBoxNo:
; mtPipeEye+36: the snap-turn mask shifts right one bit per step (0x1F -> 0 in 5 steps)
lwz r0, 36(r7)
srwi r0, r0, 1
stw r0, 36(r7)
lwz r0, 8(r7)
cmpwi r0, 0
beq mtPipeEyeStore
lfs f2, 8(r7)
fsubs f0, f1, f2
lfs f1, 12(r7)
fmuls f0, f0, f1
fadds f1, f2, f0
mtPipeEyeStore:
stfs f1, 8(r7)
lis r7, mrEyeTarget@ha
addi r7, r7, mrEyeTarget@l
lfs f0, 1980(r11)
fadds f0, f0, f1
stfs f0, 4(r7)
lfs f0, 1984(r11)
stfs f0, 8(r7)
stwu r1, -0x20(r1)
stw r5, 8(r1)
stw r6, 12(r1)
stw r9, 16(r1)
stw r10, 20(r1)
stw r12, 24(r1)
mr r7, r11
lis r10, mtHideModel@ha
addi r10, r10, mtHideModel@l
li r0, 0
stw r0, 16(r10)
lis r12, mtHandCtl@ha
addi r12, r12, mtHandCtl@l
stw r0, 4(r12)
stw r0, 8(r12)
stw r0, 36(r12)
stw r0, 40(r12)
lis r12, mtHideActor@ha
addi r12, r12, mtHideActor@l
stw r11, 0(r12)
lwz r7, 252(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawParts
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawParts
andi. r0, r7, 3
bne mtHideDrawParts
lwz r6, 24(r7)
cmplwi r6, 7
bgt mtHideDrawParts
lwz r7, 20(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawParts
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawParts
andi. r0, r7, 3
bne mtHideDrawParts
mulli r6, r6, 4
add r7, r7, r6
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawParts
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawParts
andi. r0, r7, 3
bne mtHideDrawParts
mr r9, r7
lis r11, mtHideHost@ha
stw r9, mtHideHost@l(r11)
lwz r7, 68(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawParts
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawParts
andi. r0, r7, 3
bne mtHideDrawParts
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawParts
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawParts
andi. r0, r7, 3
bne mtHideDrawParts
lwz r7, 8(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawParts
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawParts
andi. r0, r7, 3
bne mtHideDrawParts
stw r7, 0(r10)
stw r7, 20(r10)
li r0, 1
stw r0, 16(r10)
lwz r7, 112(r9)
lis r11, 0x1000
cmplw r7, r11
blt mtHideCaptureStamp
lis r11, 0x5000
cmplw r7, r11
bge mtHideCaptureStamp
andi. r0, r7, 3
bne mtHideCaptureStamp
lwz r6, 8(r7)
cmplwi r6, 16
bgt mtHideCaptureStamp
cmpwi r6, 0
beq mtHideCaptureStamp
lwz r5, 12(r7)
lis r11, 0x1000
cmplw r5, r11
blt mtHideCaptureStamp
lis r11, 0x5000
cmplw r5, r11
bge mtHideCaptureStamp
andi. r0, r5, 3
bne mtHideCaptureStamp
; The two glove parts are found by their joints, not by their place in the list (the list starts
; with the skirt for Peach and Rosalina, and with the eyes and hair for Peach's boomerang suit):
; the right hand's joint matrix is always 0xC0 bytes after the left hand's, and the two are
; neighbours, so the last neighbouring pair of parts models 0xC0 apart is (left, right).
lis r12, mtHandPick@ha
addi r12, r12, mtHandPick@l
li r7, 0
stw r7, 0(r12)
stw r7, 4(r12)
stw r7, 8(r12)
stw r7, 12(r12)
li r9, 0
mtHideChildLoop:
add r7, r5, r9
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideChildNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideChildNext
andi. r0, r7, 3
bne mtHideChildNext
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideChildNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideChildNext
andi. r0, r7, 3
bne mtHideChildNext
lis r12, mtHandPick@ha
addi r12, r12, mtHandPick@l
li r11, 0
stw r11, 12(r12)
lwz r11, 0(r7)
lis r0, 0x1037
ori r0, r0, 0x2550
cmpw r11, r0
bne mtPickDone
lwz r11, 132(r7)
lwz r0, 8(r12)
stw r11, 8(r12)
cmpwi r0, 0
beq mtPickSave
subf r0, r0, r11
cmpwi r0, 192
bne mtPickSave
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r0, 0(r12)
stw r0, 4(r11)
stw r7, 8(r11)
li r0, 1
stw r0, 12(r12)
li r0, 0
cmpwi r9, 4
ble mtPickMario
li r0, 1
mtPickMario:
stw r0, 64(r11)
mtPickSave:
stw r7, 0(r12)
mtPickDone:
lwz r7, 68(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideChildNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideChildNext
andi. r0, r7, 3
bne mtHideChildNext
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideChildNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideChildNext
andi. r0, r7, 3
bne mtHideChildNext
lwz r7, 8(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideChildNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideChildNext
andi. r0, r7, 3
bne mtHideChildNext
lis r12, mtHandPick@ha
addi r12, r12, mtHandPick@l
lwz r0, 12(r12)
cmpwi r0, 0
beq mtPickModelSave
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r0, 4(r12)
stw r0, 36(r11)
stw r7, 40(r11)
mtPickModelSave:
stw r7, 4(r12)
lwz r12, 16(r10)
mulli r0, r12, 4
add r12, r10, r0
stw r7, 20(r12)
lwz r12, 16(r10)
addi r12, r12, 1
stw r12, 16(r10)
mtHideChildNext:
addi r9, r9, 4
addi r6, r6, -1
cmpwi r6, 0
bgt mtHideChildLoop
mtHideCaptureStamp:
lwz r0, 12(r10)
stw r0, 4(r10)
mtHideDrawParts:
lis r7, mtHideActor@ha
addi r7, r7, mtHideActor@l
lwz r7, 0(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideCaptureDone
lis r11, 0x5000
cmplw r7, r11
bge mtHideCaptureDone
andi. r0, r7, 3
bne mtHideCaptureDone
lwz r7, 252(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideCaptureDone
lis r11, 0x5000
cmplw r7, r11
bge mtHideCaptureDone
andi. r0, r7, 3
bne mtHideCaptureDone
lwz r7, 172(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideCaptureDone
lis r11, 0x5000
cmplw r7, r11
bge mtHideCaptureDone
andi. r0, r7, 3
bne mtHideCaptureDone
mr r9, r7
li r6, 48
mtHideDrawLoop:
lwz r12, 16(r10)
cmplwi r12, 17
bge mtHideCaptureDone
add r5, r9, r6
lwz r7, 0(r5)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawNext
andi. r0, r7, 3
bne mtHideDrawNext
lwz r7, 56(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawNext
andi. r0, r7, 3
bne mtHideDrawNext
lwz r7, 724(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtHideDrawNext
lis r11, 0x5000
cmplw r7, r11
bge mtHideDrawNext
andi. r0, r7, 3
bne mtHideDrawNext
mulli r5, r12, 4
add r5, r10, r5
stw r7, 20(r5)
addi r12, r12, 1
stw r12, 16(r10)
mtHideDrawNext:
addi r6, r6, 4
cmpwi r6, 80
blt mtHideDrawLoop
mtHideCaptureDone:
lwz r5, 8(r1)
lwz r6, 12(r1)
lwz r9, 16(r1)
lwz r10, 20(r1)
lwz r12, 24(r1)
addi r1, r1, 0x20
b mtPreparePose
mtUseDiorama:
li r0, 0
stw r0, 28(r8)
; Cutscene camera: in the stage scene, a camera whose target is not the player. mtCine is read
; at the start of the next frame to pull the diorama camera back (mtCineDist / mtCineAdv).
mtCineCheck:
lis r11, mtCine@ha
addi r11, r11, mtCine@l
li r0, 0
stw r0, 0(r11)
lis r7, mrSceneClass@ha
lwz r7, mrSceneClass@l(r7)
lis r0, 0x1032
ori r0, r0, 0x86DC
cmpw r7, r0
bne mtCineDone
lwz r7, 580(r3)
lis r0, 0x1000
cmplw r7, r0
blt mtCineYes
lis r0, 0x5000
cmplw r7, r0
bge mtCineYes
andi. r0, r7, 3
bne mtCineYes
lwz r0, 0(r7)
lis r7, 0x1031
ori r7, r7, 0x9EF4
cmpw r0, r7
beq mtCineDone
mtCineYes:
li r0, 1
stw r0, 0(r11)
mtCineDone:
mtPreparePose:
; Latch the validated FP mode alongside this camera's slot/eye.
lis r7, rrSlot@ha
lwz r7, rrSlot@l(r7)
mulli r7, r7, 2
add r7, r7, r10
mulli r7, r7, 4
lis r11, mtNearState@ha
addi r11, r11, mtNearState@l
add r11, r11, r7
lwz r0, 28(r8)
stw r0, 0(r11)
; Private per-call pose. Never change the shared pose mailbox or its stamp.
lis r11, mtPoseScratch@ha
addi r11, r11, mtPoseScratch@l
lwz r7, 0(r12)
stw r7, 0(r11)
lwz r7, 4(r12)
stw r7, 4(r11)
lwz r7, 8(r12)
stw r7, 8(r11)
lwz r7, 12(r12)
stw r7, 12(r11)
lwz r7, 16(r12)
stw r7, 16(r11)
lwz r7, 20(r12)
stw r7, 20(r11)
lwz r7, 24(r12)
stw r7, 24(r11)
lwz r7, 28(r12)
stw r7, 28(r11)
lwz r7, 32(r12)
stw r7, 32(r11)
lwz r7, 36(r12)
stw r7, 36(r11)
lwz r7, 40(r12)
stw r7, 40(r11)
lwz r7, 44(r12)
stw r7, 44(r11)
lwz r0, 28(r8)
cmpwi r0, 1
bne mtLevelDone
lfs f5, 20(r3)
lfs f6, 36(r3)
lfs f1, 4(r11)
lfs f2, 8(r11)
fmuls f0, f1, f5
fmuls f7, f2, f6
fsubs f0, f0, f7
fmuls f8, f1, f6
fmuls f9, f2, f5
fadds f8, f8, f9
stfs f0, 4(r11)
stfs f8, 8(r11)
lfs f1, 20(r11)
lfs f2, 24(r11)
fmuls f0, f1, f5
fmuls f7, f2, f6
fsubs f0, f0, f7
fmuls f8, f1, f6
fmuls f9, f2, f5
fadds f8, f8, f9
stfs f0, 20(r11)
stfs f8, 24(r11)
lfs f1, 36(r11)
lfs f2, 40(r11)
fmuls f0, f1, f5
fmuls f7, f2, f6
fsubs f0, f0, f7
fmuls f8, f1, f6
fmuls f9, f2, f5
fadds f8, f8, f9
stfs f0, 36(r11)
stfs f8, 40(r11)
mtLevelDone:
lfs f4, 56(r8)
lwz r0, 28(r8)
cmpwi r0, 1
bne mtScaleReady
lfs f4, 52(r8)
mtScaleReady:
; Camera behind Mario (mtEyeBack above 0): keep only this eye's offset from the
; middle of the head instead of the head's offset from the recentre point, so
; the camera stays centred on Mario however far the head has drifted. The
; other eye's raw pose sits 48 bytes away in the latch.
lis r7, mtEyeBackLock@ha
lwz r7, mtEyeBackLock@l(r7)
cmpwi r7, 0
beq mtPoseTNormal
lwz r0, 28(r8)
cmpwi r0, 1
bne mtPoseTNormal
lis r7, mtEyeBack@ha
lwz r7, mtEyeBack@l(r7)
cmpwi r7, 0
beq mtPoseTNormal
addi r7, r12, 48
cmpwi r10, 1
beq mtPoseTOther
addi r7, r12, -48
mtPoseTOther:
lfs f2, 48(r8)
lfs f0, 12(r7)
lfs f1, 12(r12)
fsubs f0, f0, f1
fmuls f0, f0, f2
fmuls f0, f0, f4
stfs f0, 12(r11)
lfs f0, 28(r7)
lfs f1, 28(r12)
fsubs f0, f0, f1
fmuls f0, f0, f2
fmuls f0, f0, f4
stfs f0, 28(r11)
lfs f0, 44(r7)
lfs f1, 44(r12)
fsubs f0, f0, f1
fmuls f0, f0, f2
fmuls f0, f0, f4
stfs f0, 44(r11)
b mtPoseTDone
mtPoseTNormal:
lfs f0, 12(r12)
lfs f1, 0(r12)
lfs f2, 16(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 4(r12)
lfs f2, 20(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 24(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 12(r11)
lfs f0, 28(r12)
lfs f1, 16(r12)
lfs f2, 16(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 20(r12)
lfs f2, 20(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 24(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 28(r11)
lfs f0, 44(r12)
lfs f1, 32(r12)
lfs f2, 16(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r12)
lfs f2, 20(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 24(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 44(r11)
mtPoseTDone:
lis r7, mtPoseEye@ha
addi r7, r7, mtPoseEye@l
mulli r0, r10, 48
add r7, r7, r0
lwz r0, 0(r11)
stw r0, 0(r7)
lwz r0, 4(r11)
stw r0, 4(r7)
lwz r0, 8(r11)
stw r0, 8(r7)
lwz r0, 12(r11)
stw r0, 12(r7)
lwz r0, 16(r11)
stw r0, 16(r7)
lwz r0, 20(r11)
stw r0, 20(r7)
lwz r0, 24(r11)
stw r0, 24(r7)
lwz r0, 28(r11)
stw r0, 28(r7)
lwz r0, 32(r11)
stw r0, 32(r7)
lwz r0, 36(r11)
stw r0, 36(r7)
lwz r0, 40(r11)
stw r0, 40(r7)
lwz r0, 44(r11)
stw r0, 44(r7)
mr r12, r11
lwz r0, 28(r8)
cmpwi r0, 1
bne mtDioramaMath
mrEyeKeep:
; Clear pipes in first person (mtTube+0 = 1): while the player moves through one (mtActLog+224),
; the view turns to where he travels - up, down, around the bends - smoothly: the game's camera (r3)
; is replaced by a copy (mtTube+64) whose axes face the travel direction (worked out once per frame
; from the player's movement, eased by mtTube+40). The eyes' place is set further down as usual.
lis r7, mtTube@ha
addi r7, r7, mtTube@l
li r0, 0
stw r0, 52(r7)
lwz r0, 0(r7)
cmpwi r0, 0
beq mtTubeEnd
lis r8, mtActLog@ha
addi r8, r8, mtActLog@l
lwz r0, 224(r8)
cmpwi r0, 0
bne mtTubeIn
li r0, 0
stw r0, 32(r7)
stw r0, 36(r7)
b mtTubeEnd
mtTubeIn:
lis r8, mtHideActor@ha
lwz r8, mtHideActor@l(r8)
lis r0, 0x1000
cmplw r8, r0
blt mtTubeEnd
lis r0, 0x5000
cmplw r8, r0
bge mtTubeEnd
andi. r0, r8, 3
bne mtTubeEnd
lwz r8, 0xC0(r8)
lis r0, 0x1000
cmplw r8, r0
blt mtTubeEnd
lis r0, 0x5000
cmplw r8, r0
bge mtTubeEnd
andi. r0, r8, 3
bne mtTubeEnd
lwz r8, 0(r8)
lis r0, 0x1000
cmplw r8, r0
blt mtTubeEnd
lis r0, 0x5000
cmplw r8, r0
bge mtTubeEnd
andi. r0, r8, 3
bne mtTubeEnd
lis r11, mtFireStat@ha
addi r11, r11, mtFireStat@l
lwz r0, 4(r11)
lwz r11, 4(r7)
cmpw r0, r11
beq mtTubeUse
stw r0, 4(r7)
lfs f7, 0(r8)
lfs f8, 4(r8)
lfs f9, 8(r8)
lfs f10, 8(r7)
lfs f11, 12(r7)
lfs f12, 16(r7)
stfs f7, 8(r7)
stfs f8, 12(r7)
stfs f9, 16(r7)
lwz r0, 32(r7)
li r11, 1
stw r11, 32(r7)
cmpwi r0, 0
beq mtTubeUse
fsubs f7, f7, f10
fsubs f8, f8, f11
fsubs f9, f9, f12
fmuls f13, f7, f7
fmuls f12, f8, f8
fadds f13, f13, f12
fmuls f12, f9, f9
fadds f13, f13, f12
lfs f12, 44(r7)
.int 0xFC0D6000 ; fcmpu cr0, f13, f12
blt mtTubeUse
fmuls f13, f7, f7
fmuls f12, f8, f8
fadds f13, f13, f12
fmuls f12, f9, f9
fadds f13, f13, f12
.int 0xFD806834 ; frsqrte f12, f13
fmuls f11, f12, f12
fmuls f11, f11, f13
lfs f0, 48(r7)
fmuls f11, f11, f0
lfs f0, 56(r7)
fsubs f11, f0, f11
fmuls f12, f12, f11
fmuls f11, f12, f12
fmuls f11, f11, f13
lfs f0, 48(r7)
fmuls f11, f11, f0
lfs f0, 56(r7)
fsubs f11, f0, f11
fmuls f12, f12, f11
fmuls f7, f7, f12
fmuls f8, f8, f12
fmuls f9, f9, f12
lwz r0, 36(r7)
cmpwi r0, 0
bne mtTubeBlend
li r0, 1
stw r0, 36(r7)
b mtTubeStore
mtTubeBlend:
lfs f4, 40(r7)
lfs f10, 20(r7)
fsubs f7, f7, f10
fmuls f7, f7, f4
fadds f7, f7, f10
lfs f10, 24(r7)
fsubs f8, f8, f10
fmuls f8, f8, f4
fadds f8, f8, f10
lfs f10, 28(r7)
fsubs f9, f9, f10
fmuls f9, f9, f4
fadds f9, f9, f10
fmuls f13, f7, f7
fmuls f12, f8, f8
fadds f13, f13, f12
fmuls f12, f9, f9
fadds f13, f13, f12
.int 0xFD806834 ; frsqrte f12, f13
fmuls f11, f12, f12
fmuls f11, f11, f13
lfs f0, 48(r7)
fmuls f11, f11, f0
lfs f0, 56(r7)
fsubs f11, f0, f11
fmuls f12, f12, f11
fmuls f11, f12, f12
fmuls f11, f11, f13
lfs f0, 48(r7)
fmuls f11, f11, f0
lfs f0, 56(r7)
fsubs f11, f0, f11
fmuls f12, f12, f11
fmuls f7, f7, f12
fmuls f8, f8, f12
fmuls f9, f9, f12
mtTubeStore:
stfs f7, 20(r7)
stfs f8, 24(r7)
stfs f9, 28(r7)
mtTubeUse:
lwz r0, 36(r7)
cmpwi r0, 0
beq mtTubeEnd
; back = -direction
lfs f7, 20(r7)
fneg f7, f7
lfs f8, 24(r7)
fneg f8, f8
lfs f9, 28(r7)
fneg f9, f9
; right = up x back = (bz, 0, -bx); straight up or down: the camera's own right made square to back
fmr f4, f9
fsubs f5, f9, f9
fneg f6, f7
fmuls f13, f4, f4
fmuls f12, f6, f6
fadds f13, f13, f12
lfs f12, 60(r7)
.int 0xFC0D6000 ; fcmpu cr0, f13, f12
bge mtTubeRightOk
lfs f4, 0(r3)
lfs f5, 4(r3)
lfs f6, 8(r3)
fmuls f10, f4, f7
fmuls f11, f5, f8
fadds f10, f10, f11
fmuls f11, f6, f9
fadds f10, f10, f11
fmuls f11, f7, f10
fsubs f4, f4, f11
fmuls f11, f8, f10
fsubs f5, f5, f11
fmuls f11, f9, f10
fsubs f6, f6, f11
mtTubeRightOk:
fmuls f13, f4, f4
fmuls f12, f5, f5
fadds f13, f13, f12
fmuls f12, f6, f6
fadds f13, f13, f12
.int 0xFD806834 ; frsqrte f12, f13
fmuls f11, f12, f12
fmuls f11, f11, f13
lfs f0, 48(r7)
fmuls f11, f11, f0
lfs f0, 56(r7)
fsubs f11, f0, f11
fmuls f12, f12, f11
fmuls f11, f12, f12
fmuls f11, f11, f13
lfs f0, 48(r7)
fmuls f11, f11, f0
lfs f0, 56(r7)
fsubs f11, f0, f11
fmuls f12, f12, f11
fmuls f4, f4, f12
fmuls f5, f5, f12
fmuls f6, f6, f12
; up = back x right
fmuls f10, f8, f6
fmuls f11, f9, f5
fsubs f10, f10, f11
fmuls f11, f9, f4
fmuls f12, f7, f6
fsubs f11, f11, f12
fmuls f12, f7, f5
fmuls f13, f8, f4
fsubs f12, f12, f13
addi r11, r7, 64
lwz r0, 0(r3)
stw r0, 0(r11)
lwz r0, 4(r3)
stw r0, 4(r11)
lwz r0, 8(r3)
stw r0, 8(r11)
lwz r0, 12(r3)
stw r0, 12(r11)
lwz r0, 16(r3)
stw r0, 16(r11)
lwz r0, 20(r3)
stw r0, 20(r11)
lwz r0, 24(r3)
stw r0, 24(r11)
lwz r0, 28(r3)
stw r0, 28(r11)
lwz r0, 32(r3)
stw r0, 32(r11)
lwz r0, 36(r3)
stw r0, 36(r11)
lwz r0, 40(r3)
stw r0, 40(r11)
lwz r0, 44(r3)
stw r0, 44(r11)
lwz r0, 48(r3)
stw r0, 48(r11)
lwz r0, 52(r3)
stw r0, 52(r11)
lwz r0, 56(r3)
stw r0, 56(r11)
lwz r0, 60(r3)
stw r0, 60(r11)
lwz r0, 64(r3)
stw r0, 64(r11)
lwz r0, 68(r3)
stw r0, 68(r11)
lwz r0, 72(r3)
stw r0, 72(r11)
lwz r0, 76(r3)
stw r0, 76(r11)
lwz r0, 80(r3)
stw r0, 80(r11)
lwz r0, 84(r3)
stw r0, 84(r11)
stfs f4, 0(r11)
stfs f5, 4(r11)
stfs f6, 8(r11)
stfs f10, 16(r11)
stfs f11, 20(r11)
stfs f12, 24(r11)
stfs f7, 32(r11)
stfs f8, 36(r11)
stfs f9, 40(r11)
li r0, 1
stw r0, 52(r7)
mr r3, r11
mtTubeEnd:
lfs f4, 20(r3)
lfs f5, 40(r3)
fmuls f4, f4, f5
lfs f5, 24(r3)
lfs f6, 36(r3)
fmuls f5, f5, f6
fsubs f4, f4, f5
lfs f5, 0(r3)
fmuls f7, f4, f5
lfs f4, 16(r3)
lfs f5, 40(r3)
fmuls f4, f4, f5
lfs f5, 24(r3)
lfs f6, 32(r3)
fmuls f5, f5, f6
fsubs f4, f4, f5
lfs f5, 4(r3)
fmuls f4, f4, f5
fsubs f7, f7, f4
lfs f4, 16(r3)
lfs f5, 36(r3)
fmuls f4, f4, f5
lfs f5, 20(r3)
lfs f6, 32(r3)
fmuls f5, f5, f6
fsubs f4, f4, f5
lfs f5, 8(r3)
fmuls f4, f4, f5
fadds f7, f7, f4
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f5, 4(r8)
lfs f6, 28(r8)
.int 0xFC073000 ; fcmpu cr0, f7, f6
bge mrLookHandKeep
fneg f5, f5
mrLookHandKeep:
stfs f5, 8(r8)
rrPoseEyeReady:
lfs f1, 0(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 0(r9)
lfs f1, 0(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 4(r9)
lfs f1, 0(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r9)
lfs f1, 0(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f4, 0(r8)
lfs f5, 8(r8)
lfs f1, 0(r9)
lfs f2, 8(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f7, f1, f5
fmuls f8, f2, f4
fadds f7, f7, f8
stfs f0, 0(r9)
stfs f7, 8(r9)
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f1, 0(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fneg f0, f0
lfs f1, 12(r12)
fadds f0, f0, f1
stfs f0, 12(r9)
lfs f1, 16(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r9)
lfs f1, 16(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r9)
lfs f1, 16(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r9)
lfs f1, 16(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f4, 0(r8)
lfs f5, 8(r8)
lfs f1, 16(r9)
lfs f2, 24(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f7, f1, f5
fmuls f8, f2, f4
fadds f7, f7, f8
stfs f0, 16(r9)
stfs f7, 24(r9)
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f1, 16(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fneg f0, f0
lfs f1, 28(r12)
fadds f0, f0, f1
stfs f0, 28(r9)
lfs f1, 32(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r9)
lfs f1, 32(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 36(r9)
lfs f1, 32(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r9)
lfs f1, 32(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f4, 0(r8)
lfs f5, 8(r8)
lfs f1, 32(r9)
lfs f2, 40(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f7, f1, f5
fmuls f8, f2, f4
fadds f7, f7, f8
stfs f0, 32(r9)
stfs f7, 40(r9)
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f1, 32(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
fneg f0, f0
lfs f1, 44(r12)
fadds f0, f0, f1
lis r8, mtEyeBack@ha
lfs f1, mtEyeBack@l(r8)
lwz r8, mtEyeBack@l(r8)
cmpwi r8, 0
bne mtViewBackSet1
lis r8, mtFpBack@ha
lfs f1, mtFpBack@l(r8)
; the camera's own offset (mtEyeFit+68, + = forward): the view moves level along where it looks,
; away from Mario's head (the body drawn under the view comes along)
lis r8, mtEyeFit@ha
addi r8, r8, mtEyeFit@l
lfs f2, 68(r8)
fsubs f1, f1, f2
mtViewBackSet1:
fsubs f0, f0, f1
stfs f0, 44(r9)
; The whole distance goes straight back (level) instead of along the view's slope - looking up would
; otherwise send the camera down into the ground, looking down up into the air - and the part beyond
; the basic distance (mtLift+0) also lifts it, by mtLift+4 per unit. At distance 0 nothing changes.
lis r8, mtLift@ha
addi r8, r8, mtLift@l
lfs f2, 0(r8)
fsubs f2, f1, f2
fsubs f7, f2, f2
.int 0xFC023800 ; fcmpu cr0, f2, f7
bge mtLiftUp1
fmr f8, f7
b mtLiftK1
mtLiftUp1:
fmr f8, f2
mtLiftK1:
lfs f6, 4(r8)
fmuls f8, f8, f6
lfs f9, 36(r9)
fmuls f9, f9, f1
fsubs f8, f8, f9
lfs f9, 4(r9)
fmuls f9, f9, f8
lfs f6, 12(r9)
fsubs f6, f6, f9
stfs f6, 12(r9)
lfs f9, 20(r9)
fmuls f9, f9, f8
lfs f6, 28(r9)
fsubs f6, f6, f9
stfs f6, 28(r9)
lfs f9, 36(r9)
fmuls f9, f9, f8
lfs f6, 44(r9)
fsubs f6, f6, f9
stfs f6, 44(r9)
mtLiftEnd1:
lis r8, rrCameraMinusOne@ha
addi r8, r8, rrCameraMinusOne@l
lfs f4, 0(r8)
lfs f1, 52(r3)
lfs f2, 64(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 32(r3)
fmuls f1, f1, f2
fmuls f5, f1, f3
lfs f1, 56(r3)
lfs f2, 68(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lfs f1, 60(r3)
lfs f2, 72(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f5, 16(r8)
lfs f1, 0(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 16(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 52(r9)
lfs f1, 32(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 64(r9)
lfs f1, 16(r9)
stfs f1, 76(r9)
lfs f1, 4(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 56(r9)
lfs f1, 36(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 68(r9)
lfs f1, 20(r9)
stfs f1, 80(r9)
lfs f1, 8(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 24(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 60(r9)
lfs f1, 40(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 72(r9)
lfs f1, 24(r9)
stfs f1, 84(r9)
; Hands: keep this eye's world position and the tracking-to-world turning.
lis r7, mtHandCam@ha
addi r7, r7, mtHandCam@l
lfs f0, 0(r9)
lfs f1, 0(r12)
fmuls f0, f0, f1
lfs f1, 16(r9)
lfs f2, 16(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r9)
lfs f2, 32(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 0(r7)
lfs f0, 0(r9)
lfs f1, 4(r12)
fmuls f0, f0, f1
lfs f1, 16(r9)
lfs f2, 20(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r9)
lfs f2, 36(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 4(r7)
lfs f0, 0(r9)
lfs f1, 8(r12)
fmuls f0, f0, f1
lfs f1, 16(r9)
lfs f2, 24(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r9)
lfs f2, 40(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r7)
lfs f0, 4(r9)
lfs f1, 0(r12)
fmuls f0, f0, f1
lfs f1, 20(r9)
lfs f2, 16(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 32(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 12(r7)
lfs f0, 4(r9)
lfs f1, 4(r12)
fmuls f0, f0, f1
lfs f1, 20(r9)
lfs f2, 20(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 36(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r7)
lfs f0, 4(r9)
lfs f1, 8(r12)
fmuls f0, f0, f1
lfs f1, 20(r9)
lfs f2, 24(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 40(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r7)
lfs f0, 8(r9)
lfs f1, 0(r12)
fmuls f0, f0, f1
lfs f1, 24(r9)
lfs f2, 16(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 32(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r7)
lfs f0, 8(r9)
lfs f1, 4(r12)
fmuls f0, f0, f1
lfs f1, 24(r9)
lfs f2, 20(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 36(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 28(r7)
lfs f0, 8(r9)
lfs f1, 8(r12)
fmuls f0, f0, f1
lfs f1, 24(r9)
lfs f2, 24(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 40(r12)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r7)
mulli r11, r10, 12
add r11, r11, r7
lfs f0, 52(r9)
stfs f0, 36(r11)
lfs f0, 56(r9)
stfs f0, 40(r11)
lfs f0, 60(r9)
stfs f0, 44(r11)
li r8, 1
mulli r11, r10, 4
add r11, r11, r7
stw r8, 60(r11)
b mtCameraStamp
mtDioramaMath:
; The world map's own turn (mtMapYaw, see mtMapYawInput): the game's camera (r3) is turned round what
; it looks at (its target, +64) by W = the yaw about the vertical: rows R' = W R, translation so the
; target stays put, position turned too; the copy (mtMapYaw+36) is used from here on.
lis r7, mtMapYaw@ha
addi r7, r7, mtMapYaw@l
li r0, 0
stw r0, 4(r7)
lwz r0, 0(r7)
cmpwi r0, 0
beq mtMapYawSkip
lis r11, mrSceneClass@ha
lwz r11, mrSceneClass@l(r11)
cmpwi r11, 0
beq mtMapYawSkip
lis r0, 0x1032
ori r0, r0, 0x86DC
cmpw r11, r0
beq mtMapYawSkip
lfs f7, 16(r7)
lfs f8, 20(r7)
addi r11, r7, 36
lwz r0, 0(r3)
stw r0, 0(r11)
lwz r0, 4(r3)
stw r0, 4(r11)
lwz r0, 8(r3)
stw r0, 8(r11)
lwz r0, 12(r3)
stw r0, 12(r11)
lwz r0, 16(r3)
stw r0, 16(r11)
lwz r0, 20(r3)
stw r0, 20(r11)
lwz r0, 24(r3)
stw r0, 24(r11)
lwz r0, 28(r3)
stw r0, 28(r11)
lwz r0, 32(r3)
stw r0, 32(r11)
lwz r0, 36(r3)
stw r0, 36(r11)
lwz r0, 40(r3)
stw r0, 40(r11)
lwz r0, 44(r3)
stw r0, 44(r11)
lwz r0, 48(r3)
stw r0, 48(r11)
lwz r0, 52(r3)
stw r0, 52(r11)
lwz r0, 56(r3)
stw r0, 56(r11)
lwz r0, 60(r3)
stw r0, 60(r11)
lwz r0, 64(r3)
stw r0, 64(r11)
lwz r0, 68(r3)
stw r0, 68(r11)
lwz r0, 72(r3)
stw r0, 72(r11)
lwz r0, 76(r3)
stw r0, 76(r11)
lwz r0, 80(r3)
stw r0, 80(r11)
lwz r0, 84(r3)
stw r0, 84(r11)
lfs f9, 64(r3)
lfs f10, 68(r3)
lfs f11, 72(r3)
; row 0
lfs f0, 0(r3)
lfs f1, 4(r3)
lfs f2, 8(r3)
fmuls f4, f0, f9
fmuls f5, f1, f10
fadds f4, f4, f5
fmuls f5, f2, f11
fadds f4, f4, f5
fmuls f5, f7, f0
fmuls f6, f8, f2
fadds f5, f5, f6
fmuls f6, f7, f2
fmuls f12, f8, f0
fsubs f6, f6, f12
stfs f5, 0(r11)
stfs f6, 8(r11)
fmuls f12, f5, f9
fmuls f13, f1, f10
fadds f12, f12, f13
fmuls f13, f6, f11
fadds f12, f12, f13
fsubs f4, f4, f12
lfs f0, 12(r3)
fadds f4, f4, f0
stfs f4, 12(r11)
; row 1
lfs f0, 16(r3)
lfs f1, 20(r3)
lfs f2, 24(r3)
fmuls f4, f0, f9
fmuls f5, f1, f10
fadds f4, f4, f5
fmuls f5, f2, f11
fadds f4, f4, f5
fmuls f5, f7, f0
fmuls f6, f8, f2
fadds f5, f5, f6
fmuls f6, f7, f2
fmuls f12, f8, f0
fsubs f6, f6, f12
stfs f5, 16(r11)
stfs f6, 24(r11)
fmuls f12, f5, f9
fmuls f13, f1, f10
fadds f12, f12, f13
fmuls f13, f6, f11
fadds f12, f12, f13
fsubs f4, f4, f12
lfs f0, 28(r3)
fadds f4, f4, f0
stfs f4, 28(r11)
; row 2
lfs f0, 32(r3)
lfs f1, 36(r3)
lfs f2, 40(r3)
fmuls f4, f0, f9
fmuls f5, f1, f10
fadds f4, f4, f5
fmuls f5, f2, f11
fadds f4, f4, f5
fmuls f5, f7, f0
fmuls f6, f8, f2
fadds f5, f5, f6
fmuls f6, f7, f2
fmuls f12, f8, f0
fsubs f6, f6, f12
stfs f5, 32(r11)
stfs f6, 40(r11)
fmuls f12, f5, f9
fmuls f13, f1, f10
fadds f12, f12, f13
fmuls f13, f6, f11
fadds f12, f12, f13
fsubs f4, f4, f12
lfs f0, 44(r3)
fadds f4, f4, f0
stfs f4, 44(r11)
; position: target + W (position - target)
lfs f0, 52(r3)
fsubs f0, f0, f9
lfs f2, 60(r3)
fsubs f2, f2, f11
fmuls f4, f7, f0
fmuls f5, f8, f2
fadds f4, f4, f5
fadds f4, f4, f9
stfs f4, 52(r11)
fmuls f4, f7, f2
fmuls f5, f8, f0
fsubs f4, f4, f5
fadds f4, f4, f11
stfs f4, 60(r11)
li r0, 1
stw r0, 4(r7)
mr r3, r11
mtMapYawSkip:
; Level horizon (mtLevel+0 = 1): the game's camera (r3: its 3x4 view at 0..44, position at 52) is
; replaced by a level copy - same place, same heading, no pitch or roll - so the world stands
; upright and you look down with your own head. A camera looking (almost) straight down keeps its
; own matrix.
lis r7, mtLevel@ha
addi r7, r7, mtLevel@l
lwz r0, 0(r7)
cmpwi r0, 0
beq mtLevelSkip
lfs f7, 32(r3)
lfs f8, 40(r3)
fmuls f9, f7, f7
fmuls f10, f8, f8
fadds f9, f9, f10
lfs f10, 8(r7)
.int 0xFC095000 ; fcmpu cr0, f9, f10
blt mtLevelSkip
.int 0xFD404834 ; frsqrte f10, f9
lfs f12, 12(r7)
fmuls f11, f10, f10
fmuls f11, f11, f9
fmuls f11, f11, f12
lfs f12, 16(r7)
fsubs f11, f12, f11
fmuls f10, f10, f11
lfs f12, 12(r7)
fmuls f11, f10, f10
fmuls f11, f11, f9
fmuls f11, f11, f12
lfs f12, 16(r7)
fsubs f11, f12, f11
fmuls f10, f10, f11
fmuls f7, f7, f10
fmuls f8, f8, f10
addi r11, r7, 32
; position, target (52..72) as they are
lwz r0, 52(r3)
stw r0, 52(r11)
lwz r0, 56(r3)
stw r0, 56(r11)
lwz r0, 60(r3)
stw r0, 60(r11)
lwz r0, 64(r3)
stw r0, 64(r11)
lwz r0, 68(r3)
stw r0, 68(r11)
lwz r0, 72(r3)
stw r0, 72(r11)
; rows: right = (bz, 0, -bx), up = (0, 1, 0), back = (bx, 0, bz); translation = -rows . position
lfs f12, 20(r7)
stfs f8, 0(r11)
stfs f12, 4(r11)
fneg f9, f7
stfs f9, 8(r11)
stfs f12, 16(r11)
lfs f9, 24(r7)
stfs f9, 20(r11)
stfs f12, 24(r11)
stfs f7, 32(r11)
stfs f12, 36(r11)
stfs f8, 40(r11)
; the camera's eye from its own matrix (-R^T t), not its stored position: the level copy stands
; exactly where the game's view stands
lfs f0, 0(r3)
lfs f1, 12(r3)
fmuls f10, f0, f1
lfs f0, 16(r3)
lfs f1, 28(r3)
fmuls f0, f0, f1
fadds f10, f10, f0
lfs f0, 32(r3)
lfs f1, 44(r3)
fmuls f0, f0, f1
fadds f10, f10, f0
fneg f10, f10
lfs f0, 4(r3)
lfs f1, 12(r3)
fmuls f11, f0, f1
lfs f0, 20(r3)
lfs f1, 28(r3)
fmuls f0, f0, f1
fadds f11, f11, f0
lfs f0, 36(r3)
lfs f1, 44(r3)
fmuls f0, f0, f1
fadds f11, f11, f0
fneg f11, f11
lfs f0, 8(r3)
lfs f1, 12(r3)
fmuls f12, f0, f1
lfs f0, 24(r3)
lfs f1, 28(r3)
fmuls f0, f0, f1
fadds f12, f12, f0
lfs f0, 40(r3)
lfs f1, 44(r3)
fmuls f0, f0, f1
fadds f12, f12, f0
fneg f12, f12
fmuls f9, f8, f10
fmuls f0, f7, f12
fsubs f9, f9, f0
fneg f9, f9
stfs f9, 12(r11)
fneg f9, f11
stfs f9, 28(r11)
fmuls f9, f7, f10
fmuls f0, f8, f12
fadds f9, f9, f0
fneg f9, f9
stfs f9, 44(r11)
lwz r8, 4(r7)
addi r8, r8, 1
stw r8, 4(r7)
mr r3, r11
mtLevelSkip:
lis r8, rrCameraMinusOne@ha
addi r8, r8, rrCameraMinusOne@l
lfs f4, 0(r8)
lfs f1, 52(r3)
lfs f2, 64(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 32(r3)
fmuls f1, f1, f2
fmuls f5, f1, f3
lfs f1, 56(r3)
lfs f2, 68(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lfs f1, 60(r3)
lfs f2, 72(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lis r8, rrDioramaAdvance@ha
addi r8, r8, rrDioramaAdvance@l
lfs f6, 0(r8)
fmuls f6, f6, f5
lfs f1, 0(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 0(r9)
lfs f1, 0(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 4(r9)
lfs f1, 0(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r9)
lfs f1, 0(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 12(r12)
fadds f0, f0, f1
stfs f0, 12(r9)
lfs f1, 16(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r9)
lfs f1, 16(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r9)
lfs f1, 16(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r9)
lfs f1, 16(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 28(r12)
fadds f0, f0, f1
stfs f0, 28(r9)
lfs f1, 32(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r9)
lfs f1, 32(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 36(r9)
lfs f1, 32(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r9)
lfs f1, 32(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 44(r12)
fadds f0, f0, f1
stfs f0, 44(r9)
lis r8, rrCameraMinusOne@ha
addi r8, r8, rrCameraMinusOne@l
lfs f4, 0(r8)
lfs f1, 52(r3)
lfs f2, 64(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 32(r3)
fmuls f1, f1, f2
fmuls f5, f1, f3
lfs f1, 56(r3)
lfs f2, 68(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lfs f1, 60(r3)
lfs f2, 72(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lis r8, rrDioramaDistance@ha
addi r8, r8, rrDioramaDistance@l
lfs f1, 0(r8)
fmuls f5, f5, f1
lfs f1, 0(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 16(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 52(r9)
lfs f1, 32(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 64(r9)
lfs f1, 16(r9)
stfs f1, 76(r9)
lfs f1, 4(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 36(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 56(r9)
lfs f1, 36(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 68(r9)
lfs f1, 20(r9)
stfs f1, 80(r9)
lfs f1, 8(r9)
lfs f2, 12(r9)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 24(r9)
lfs f2, 28(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 44(r9)
fmuls f1, f1, f2
fadds f0, f0, f1
fmuls f0, f0, f4
stfs f0, 60(r9)
lfs f1, 40(r9)
fmuls f1, f1, f5
fmuls f1, f1, f4
fadds f1, f0, f1
stfs f1, 72(r9)
lfs f1, 24(r9)
stfs f1, 84(r9)
mtCameraStamp:
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r8, 0(r12)
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 4
lis r12, rrCameraPoseSequence@ha
addi r12, r12, rrCameraPoseSequence@l
add r12, r12, r11
stw r8, 0(r12)
lis r12, rrPoseUsed@ha
addi r12, r12, rrPoseUsed@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
mr r3, r9
blr
rrPoseFallback:
rrCameraExit:
blr


rrSecondRecord:
.int 0
rrShadowSkipped:
.int 0
; Shadows for both eyes. 1 = the second eye draws its own shadow map instead
; of reusing the first eye's; 0 = original behaviour (skip in the second eye).
; This word has to stay directly after rrShadowSkipped.
rrShadowBothEyes:
.int 0

0x026EA934 = rrShadowOriginalAlloc:
rrShadowAlloc:
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
lwz r11, 0(r12)
cmpwi r11, 1
bne rrShadowAllocGo
lwz r11, 8(r12)
cmpwi r11, 0
beq rrShadowSkipAlloc
rrShadowAllocGo:
b rrShadowOriginalAlloc
rrShadowSkipAlloc:
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
blr
0x02450A8C = bla rrShadowAlloc

0x026EA95C = rrShadowOriginalDraw:
rrShadowDraw:
lis r12, rrSecondRecord@ha
addi r12, r12, rrSecondRecord@l
lwz r11, 0(r12)
cmpwi r11, 1
bne rrShadowDrawGo
lwz r11, 8(r12)
cmpwi r11, 0
beq rrShadowSkipDraw
rrShadowDrawGo:
b rrShadowOriginalDraw
rrShadowSkipDraw:
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
blr
0x02450A98 = bla rrShadowDraw

; Root Calc receives its scene-owner object in r31 at 022F37F0.
; Preserve scratch registers and CR across the displaced mr r3,r31.
mrSceneProbe:
stwu r1, -0x20(r1)
stw r0, 8(r1)
.int 0x7C000026 ; mfcr r0
stw r0, 12(r1)
stw r11, 16(r1)
stw r12, 20(r1)
lis r12, mtHideModel@ha
addi r12, r12, mtHideModel@l
lwz r11, 12(r12)
addi r11, r11, 1
stw r11, 12(r12)
mr r3, r31
lis r12, mrSceneClass@ha
addi r12, r12, mrSceneClass@l
li r11, 0
stw r11, 0(r12)
lis r12, tsScene@ha
stw r11, tsScene@l(r12)
lis r12, pfState@ha
addi r12, r12, pfState@l
stw r11, 8(r12)
stw r11, 24(r12)
lis r12, mrSceneClass@ha
addi r12, r12, mrSceneClass@l
cmpwi r3, 0
beq mrSceneDone
lwz r11, 8(r3)
cmpwi r11, 0
beq mrSceneDone
lis r0, 0x1000
cmplw r11, r0
blt mrSceneDone
lis r0, 0x5000
cmplw r11, r0
bge mrSceneDone
lwz r11, 0x5C(r11)
cmpwi r11, 0
beq mrSceneDone
lis r0, 0x1000
cmplw r11, r0
blt mrSceneDone
lis r0, 0x5000
cmplw r11, r0
bge mrSceneDone
lis r12, pfState@ha
addi r12, r12, pfState@l
li r0, 0
stw r0, 8(r12)
stw r11, 20(r12)
lwz r0, 0(r11)
lis r12, 0x1027
ori r12, r12, 0xF388
cmpw r0, r12
bne pfStateDone
lwz r0, 0x104(r11)
lis r12, pfState@ha
addi r12, r12, pfState@l
stw r0, 12(r12)
cmpwi r0, 9
blt pfStateDone
cmpwi r0, 12
bgt pfStateDone
cmpwi r0, 9
beq pfStateLower
cmpwi r0, 12
beq pfStateUpper
li r0, 2
b pfStateStore
pfStateLower:
li r0, 1
b pfStateStore
pfStateUpper:
li r0, 3
pfStateStore:
stw r0, 8(r12)
pfStateDone:
lis r12, mrSceneClass@ha
addi r12, r12, mrSceneClass@l
lis r12, tsScene@ha
stw r11, tsScene@l(r12)
lis r12, mrSceneClass@ha
addi r12, r12, mrSceneClass@l
lwz r11, 0(r11)
stw r11, 0(r12)
mrSceneDone:
lis r11, rrDioramaDistance@ha
lis r0, 0x3F26
ori r0, r0, 0x6666
stw r0, rrDioramaDistance@l(r11)
lis r11, rrDioramaAdvance@ha
lis r0, 0x3EB3
ori r0, r0, 0x3333
stw r0, rrDioramaAdvance@l(r11)
lwz r11, 0(r12)
lis r0, 0x1027
ori r0, r0, 0xF388
cmpw r11, r0
bne mrIntroFactorsDone
lis r11, rrDioramaDistance@ha
lis r0, 0x3EBD
ori r0, r0, 0x70A4
stw r0, rrDioramaDistance@l(r11)
lis r11, rrDioramaAdvance@ha
lis r0, 0x3F21
ori r0, r0, 0x47AE
stw r0, rrDioramaAdvance@l(r11)
mrIntroFactorsDone:
mrCineStart:
lwz r11, 0(r12)
lis r0, 0x1032
ori r0, r0, 0x86DC
cmpw r11, r0
bne mrCineDone
lis r11, mtCine@ha
lwz r11, mtCine@l(r11)
cmpwi r11, 0
beq mrCineDone
lis r11, mtCineDist@ha
addi r11, r11, mtCineDist@l
lwz r0, 0(r11)
lwz r12, 4(r11)
lis r11, rrDioramaDistance@ha
stw r0, rrDioramaDistance@l(r11)
lis r11, rrDioramaAdvance@ha
stw r12, rrDioramaAdvance@l(r11)
mrCineDone:
lwz r12, 20(r1)
lwz r11, 16(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 255,r0
lwz r0, 8(r1)
addi r1, r1, 0x20
b mrSceneProbeReturn
0x022F37F4 = mrSceneProbeReturn:
0x022F37F0 = ba mrSceneProbe

rrPoseHeader:
.int 0x43545048
.int 5
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrPoseLatch0:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrPoseUsed:
.int 0
mrEyeTarget:
.int 0
.int 0
.int 0
.int 0x43110000
.int 0x42C80000
.int 0x3F2147AE
mrSceneClass:
.int 0
mrLookCos:
.int 0x3F800000
mrLookSin:
.int 0
mrLookSinEff:
.int 0
.int 0x3D3EA2F1
.int 0x3E19999A
.int 0x3F800000
.int 0x3F000000
.int 0x00000000
.int 0xBF666666
.int 0x3E99999A

; First-person snap turning. One push of the right stick turns the view by one
; step; the stick has to come back before it can turn again. Sine and cosine of
; the step as floats - the sine word set to 0 gives the original smooth turning.
;   55 deg: cos 0x3F12D5E8 sin 0x3F51B3F3   60 deg: cos 0x3F000000 sin 0x3F5DB3D7
;   45 deg: cos 0x3F3504F3 sin 0x3F3504F3   30 deg: cos 0x3F5DB3D7 sin 0x3F000000
;   90 deg: cos 0x00000000 sin 0x3F800000
; The stick fires at 0.6 and re-arms below 0.3.
mrSnapSin:
.int 0x3F51B3F3
mrSnapCos:
.int 0x3F12D5E8
mrSnapHeld:
.int 0
mrSnapFire:
.int 0x3F19999A

mrLookInput:
stwu r1, -0x30(r1)
mflr r0
stw r0, 0x34(r1)
stw r4, 8(r1)
stw r6, 12(r1)
bl import.vpad.VPADRead
lwz r4, 8(r1)
lwz r6, 12(r1)
cmpwi r3, 0
ble mrLookInputDone
; one more pad read = one more game frame (the fireball counters in mtFireStat use it)
lis r12, mtFireStat@ha
addi r12, r12, mtFireStat@l
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
; Motion controls: the VR controllers are written into the pad state before
; anything else reads it. Nothing here depends on Cemu's input configuration.
lis r9, mtPad@ha
addi r9, r9, mtPad@l
; B runs only: forget which sources pressed X on the last read (mtRunB: +12 B does, +16 something else does)
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 0
stw r0, 12(r12)
stw r0, 16(r12)
lwz r11, 0(r9)
cmpwi r11, 0
beq mtMotionDone
lis r7, mtMotionData@ha
addi r7, r7, mtMotionData@l
li r5, 0
lis r6, 65535
ori r6, r6, 65535
lwz r11, 16(r9)
cmpwi r11, 0
beq mtMotionLeftDone
lwz r11, 68(r9)
li r12, 1
and r12, r11, r12
cmpwi r12, 0
beq mtMotionLeftDoneBit0
ori r5, r5, 8192
lis r12, 65535
ori r12, r12, 57343
and r6, r6, r12
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 1
stw r0, 16(r12)
mtMotionLeftDoneBit0:
li r12, 2
and r12, r11, r12
cmpwi r12, 0
beq mtMotionLeftDoneBit1
ori r5, r5, 4096
lis r12, 65535
ori r12, r12, 61439
and r6, r6, r12
mtMotionLeftDoneBit1:
li r12, 16
and r12, r11, r12
cmpwi r12, 0
beq mtMotionLeftDoneBit2
ori r5, r5, 128
lis r12, 65535
ori r12, r12, 65407
and r6, r6, r12
mtMotionLeftDoneBit2:
li r12, 32
and r12, r11, r12
cmpwi r12, 0
beq mtMotionLeftDoneBit3
ori r5, r5, 32
lis r12, 65535
ori r12, r12, 65503
and r6, r6, r12
mtMotionLeftDoneBit3:
li r12, 8
and r12, r11, r12
cmpwi r12, 0
beq mtMotionLeftDoneBit4
ori r5, r5, 8
lis r12, 65535
ori r12, r12, 65527
and r6, r6, r12
mtMotionLeftDoneBit4:
li r12, 4
and r12, r11, r12
cmpwi r12, 0
beq mtMotionLeftDoneBit5
ori r5, r5, 4
lis r12, 65535
ori r12, r12, 65531
and r6, r6, r12
mtMotionLeftDoneBit5:
mtMotionLeftDone:
lwz r11, 88(r9)
cmpwi r11, 0
beq mtMotionRightDone
lwz r11, 140(r9)
li r12, 1
and r12, r11, r12
cmpwi r12, 0
beq mtMotionRightDoneBit0
ori r5, r5, 32768
lis r12, 65535
ori r12, r12, 32767
and r6, r6, r12
mtMotionRightDoneBit0:
li r12, 2
and r12, r11, r12
cmpwi r12, 0
beq mtMotionRightDoneBit1
; the left grip held (the left controller tracked) turns the right B into the game's own B (back in the menus, the second
; jump button): 16384, with its bit taken out of the real pad's
lwz r12, 16(r9)
cmpwi r12, 0
beq mtMotionRightBX
lwz r12, 68(r9)
andi. r12, r12, 32
beq mtMotionRightBX
ori r5, r5, 16384
lis r12, 65535
ori r12, r12, 49151
and r6, r6, r12
b mtMotionRightDoneBit1
mtMotionRightBX:
ori r5, r5, 8192
lis r12, 65535
ori r12, r12, 57343
and r6, r6, r12
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 1
stw r0, 12(r12)
mtMotionRightDoneBit1:
; the right trigger runs: held, it holds the game's X (run / pick up / fireball)
li r12, 16
and r12, r11, r12
cmpwi r12, 0
beq mtMotionRightDoneBit2
ori r5, r5, 8192
lis r12, 65535
ori r12, r12, 57343
and r6, r6, r12
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 1
stw r0, 16(r12)
mtMotionRightDoneBit2:
li r12, 32
and r12, r11, r12
cmpwi r12, 0
beq mtMotionRightDoneBit3
ori r5, r5, 16
lis r12, 65535
ori r12, r12, 65519
and r6, r6, r12
mtMotionRightDoneBit3:
mtMotionRightDone:
li r8, 0
lwz r11, 16(r9)
cmpwi r11, 0
beq mtMotionLeftStick
lfs f4, 80(r9)
lfs f5, 84(r9)
fmuls f6, f4, f4
fmuls f7, f5, f5
fadds f6, f6, f7
lfs f0, 0(r7)
.int 0xFC060000 ; fcmpu cr0, f6, f0
blt mtMotionLeftStick
li r8, 1
mtMotionLeftStick:
li r10, 0
lwz r11, 88(r9)
cmpwi r11, 0
beq mtMotionRightStick
lfs f8, 152(r9)
lfs f9, 156(r9)
fmuls f6, f8, f8
fmuls f7, f9, f9
fadds f6, f6, f7
lfs f0, 0(r7)
.int 0xFC060000 ; fcmpu cr0, f6, f0
blt mtMotionRightStick
li r10, 1
mtMotionRightStick:
; Geste: linker Controller am Kopf schaltet das Steuerkreuz auf.
li r11, 0
lwz r12, 16(r9)
cmpwi r12, 0
beq mtMotionReach
lfs f10, 4(r9)
lfs f11, 32(r9)
fsubs f10, f10, f11
fmuls f12, f10, f10
lfs f10, 8(r9)
lfs f11, 48(r9)
fsubs f10, f10, f11
fmuls f10, f10, f10
fadds f12, f12, f10
lfs f10, 12(r9)
lfs f11, 64(r9)
fsubs f10, f10, f11
fmuls f10, f10, f10
fadds f12, f12, f10
lfs f0, 4(r7)
.int 0xFC0C0000 ; fcmpu cr0, f12, f0
bge mtMotionReach
; ... and held up at the head (not more than mtMotionData+20 below it): looking down at a hand that
; rests in front of the chest must not turn the right stick into the D-pad
lfs f10, 48(r9)
lfs f11, 8(r9)
fsubs f10, f10, f11
lfs f0, 20(r7)
.int 0xFC0A0000 ; fcmpu cr0, f10, f0
blt mtMotionReach
li r11, 1
mtMotionReach:
cmpwi r11, 0
beq mtMotionGestureDone
lfs f10, 152(r9)
lfs f11, 156(r9)
lfs f0, 8(r7)
.int 0xFC0A0000 ; fcmpu cr0, f10, f0
ble mtMotionNoRight
ori r5, r5, 1024
lis r12, 65535
ori r12, r12, 64511
and r6, r6, r12
mtMotionNoRight:
lfs f0, 12(r7)
.int 0xFC0A0000 ; fcmpu cr0, f10, f0
bge mtMotionNoLeft
ori r5, r5, 2048
lis r12, 65535
ori r12, r12, 63487
and r6, r6, r12
mtMotionNoLeft:
lfs f0, 8(r7)
.int 0xFC0B0000 ; fcmpu cr0, f11, f0
ble mtMotionNoUp
ori r5, r5, 512
lis r12, 65535
ori r12, r12, 65023
and r6, r6, r12
mtMotionNoUp:
lfs f0, 12(r7)
.int 0xFC0B0000 ; fcmpu cr0, f11, f0
bge mtMotionNoDown
ori r5, r5, 256
lis r12, 65535
ori r12, r12, 65279
and r6, r6, r12
mtMotionNoDown:
li r10, 1
lfs f8, 16(r7)
lfs f9, 16(r7)
mtMotionGestureDone:
lis r11, mtSwing@ha
addi r11, r11, mtSwing@l
lwz r12, 0(r11)
cmpwi r12, 0
beq mtSwingDone
li r12, 0
stw r12, 64(r11)
lwz r12, 88(r9)
cmpwi r12, 0
beq mtSwingGone
lfs f0, 104(r9)
lfs f1, 4(r9)
fsubs f0, f0, f1
lfs f1, 120(r9)
lfs f2, 8(r9)
fsubs f1, f1, f2
lfs f2, 136(r9)
lfs f3, 12(r9)
fsubs f2, f2, f3
lwz r12, 24(r11)
cmpwi r12, 0
beq mtSwingStore
lfs f3, 32(r11)
fsubs f3, f0, f3
lfs f6, 36(r11)
fsubs f6, f1, f6
lfs f7, 40(r11)
fsubs f7, f2, f7
lwz r12, 0(r11)
cmpwi r12, 1
bne mtSwingCast
fmuls f10, f3, f3
fmuls f11, f6, f6
fadds f10, f10, f11
fmuls f11, f7, f7
fadds f10, f10, f11
lfs f11, 4(r11)
.int 0xFC0A5800 ; fcmpu cr0, f10, f11
ble mtSwingStore
li r12, 1
stw r12, 64(r11)
b mtSwingStore
mtSwingCast:
fmuls f10, f0, f3
fmuls f11, f1, f6
fadds f10, f10, f11
fmuls f11, f2, f7
fadds f10, f10, f11
fmuls f11, f0, f0
fmuls f12, f1, f1
fadds f11, f11, f12
fmuls f12, f2, f2
fadds f11, f11, f12
lfs f12, 52(r11)
.int 0xFC0B6000 ; fcmpu cr0, f11, f12
blt mtSwingStore
fmuls f12, f10, f10
fsubs f13, f10, f10
.int 0xFC0A6800 ; fcmpu cr0, f10, f13
blt mtSwingBack
ble mtSwingStore
lwz r12, 68(r11)
cmpwi r12, 0
beq mtSwingStore
lfs f13, 48(r11)
fmuls f13, f13, f11
.int 0xFC0C6800 ; fcmpu cr0, f12, f13
ble mtSwingStore
li r12, 1
stw r12, 64(r11)
li r12, 0
stw r12, 68(r11)
b mtSwingStore
mtSwingBack:
lfs f13, 44(r11)
fmuls f13, f13, f11
.int 0xFC0C6800 ; fcmpu cr0, f12, f13
ble mtSwingStore
li r12, 1
stw r12, 68(r11)
lwz r12, 56(r11)
stw r12, 60(r11)
mtSwingStore:
stfs f0, 32(r11)
stfs f1, 36(r11)
stfs f2, 40(r11)
li r12, 1
stw r12, 24(r11)
b mtSwingEnd
mtSwingGone:
li r12, 0
stw r12, 24(r11)
stw r12, 68(r11)
mtSwingEnd:
lwz r12, 68(r11)
cmpwi r12, 0
beq mtSwingWinDone
lwz r12, 60(r11)
addi r12, r12, -1
stw r12, 60(r11)
cmpwi r12, 0
bgt mtSwingWinDone
li r12, 0
stw r12, 68(r11)
mtSwingWinDone:
lwz r12, 20(r11)
cmpwi r12, 0
beq mtSwingNoCool
addi r12, r12, -1
stw r12, 20(r11)
mtSwingNoCool:
lwz r12, 16(r11)
cmpwi r12, 0
beq mtSwingNoHold
addi r12, r12, -1
stw r12, 16(r11)
b mtSwingPress
mtSwingNoHold:
lwz r12, 64(r11)
cmpwi r12, 0
beq mtSwingDone
lwz r12, 20(r11)
cmpwi r12, 0
bne mtSwingDone
; holding something picked up by touch: only the hand holding it throws it
lis r12, mtGrab@ha
lwz r12, mtGrab@l(r12)
cmpwi r12, 0
beq mtSwingFree
lis r12, mtGrabHand@ha
lwz r12, mtGrabHand@l(r12)
cmpwi r12, 1
bne mtSwingDone
mtSwingFree:
lwz r12, 8(r11)
stw r12, 16(r11)
lwz r12, 12(r11)
stw r12, 20(r11)
; the first read of the attack gesture: an X press even if B already holds X
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 1
stw r0, 8(r12)
mtSwingPress:
ori r5, r5, 8192
lis r12, 65535
ori r12, r12, 57343
and r6, r6, r12
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 1
stw r0, 16(r12)
mtSwingDone:
; the same attack gesture with the left controller (mtSwingL: its own switch, thresholds and state)
lis r11, mtSwingL@ha
addi r11, r11, mtSwingL@l
lwz r12, 0(r11)
cmpwi r12, 0
beq mtSwingDoneL
li r12, 0
stw r12, 64(r11)
lwz r12, 16(r9)
cmpwi r12, 0
beq mtSwingGoneL
lfs f0, 32(r9)
lfs f1, 4(r9)
fsubs f0, f0, f1
lfs f1, 48(r9)
lfs f2, 8(r9)
fsubs f1, f1, f2
lfs f2, 64(r9)
lfs f3, 12(r9)
fsubs f2, f2, f3
lwz r12, 24(r11)
cmpwi r12, 0
beq mtSwingStoreL
lfs f3, 32(r11)
fsubs f3, f0, f3
lfs f6, 36(r11)
fsubs f6, f1, f6
lfs f7, 40(r11)
fsubs f7, f2, f7
lwz r12, 0(r11)
cmpwi r12, 1
bne mtSwingCastL
fmuls f10, f3, f3
fmuls f11, f6, f6
fadds f10, f10, f11
fmuls f11, f7, f7
fadds f10, f10, f11
lfs f11, 4(r11)
.int 0xFC0A5800 ; fcmpu cr0, f10, f11
ble mtSwingStoreL
li r12, 1
stw r12, 64(r11)
b mtSwingStoreL
mtSwingCastL:
fmuls f10, f0, f3
fmuls f11, f1, f6
fadds f10, f10, f11
fmuls f11, f2, f7
fadds f10, f10, f11
fmuls f11, f0, f0
fmuls f12, f1, f1
fadds f11, f11, f12
fmuls f12, f2, f2
fadds f11, f11, f12
lfs f12, 52(r11)
.int 0xFC0B6000 ; fcmpu cr0, f11, f12
blt mtSwingStoreL
fmuls f12, f10, f10
fsubs f13, f10, f10
.int 0xFC0A6800 ; fcmpu cr0, f10, f13
blt mtSwingBackL
ble mtSwingStoreL
lwz r12, 68(r11)
cmpwi r12, 0
beq mtSwingStoreL
lfs f13, 48(r11)
fmuls f13, f13, f11
.int 0xFC0C6800 ; fcmpu cr0, f12, f13
ble mtSwingStoreL
li r12, 1
stw r12, 64(r11)
li r12, 0
stw r12, 68(r11)
b mtSwingStoreL
mtSwingBackL:
lfs f13, 44(r11)
fmuls f13, f13, f11
.int 0xFC0C6800 ; fcmpu cr0, f12, f13
ble mtSwingStoreL
li r12, 1
stw r12, 68(r11)
lwz r12, 56(r11)
stw r12, 60(r11)
mtSwingStoreL:
stfs f0, 32(r11)
stfs f1, 36(r11)
stfs f2, 40(r11)
li r12, 1
stw r12, 24(r11)
b mtSwingEndL
mtSwingGoneL:
li r12, 0
stw r12, 24(r11)
stw r12, 68(r11)
mtSwingEndL:
lwz r12, 68(r11)
cmpwi r12, 0
beq mtSwingWinDoneL
lwz r12, 60(r11)
addi r12, r12, -1
stw r12, 60(r11)
cmpwi r12, 0
bgt mtSwingWinDoneL
li r12, 0
stw r12, 68(r11)
mtSwingWinDoneL:
lwz r12, 20(r11)
cmpwi r12, 0
beq mtSwingNoCoolL
addi r12, r12, -1
stw r12, 20(r11)
mtSwingNoCoolL:
lwz r12, 16(r11)
cmpwi r12, 0
beq mtSwingNoHoldL
addi r12, r12, -1
stw r12, 16(r11)
b mtSwingPressL
mtSwingNoHoldL:
lwz r12, 64(r11)
cmpwi r12, 0
beq mtSwingDoneL
lwz r12, 20(r11)
cmpwi r12, 0
bne mtSwingDoneL
lis r12, mtGrab@ha
lwz r12, mtGrab@l(r12)
cmpwi r12, 0
beq mtSwingFreeL
lis r12, mtGrabHand@ha
lwz r12, mtGrabHand@l(r12)
cmpwi r12, 0
bne mtSwingDoneL
mtSwingFreeL:
lwz r12, 8(r11)
stw r12, 16(r11)
lwz r12, 12(r11)
stw r12, 20(r11)
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 1
stw r0, 8(r12)
mtSwingPressL:
ori r5, r5, 8192
lis r12, 65535
ori r12, r12, 57343
and r6, r6, r12
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
li r0, 1
stw r0, 16(r12)
mtSwingDoneL:
; the frame in which X went down (kept in mtFireStat for the fireball summary)
lis r11, mtFireStat@ha
addi r11, r11, mtFireStat@l
andi. r7, r5, 8192
li r7, 0
beq mtFireXNow
li r7, 1
mtFireXNow:
lwz r12, 84(r11)
stw r7, 84(r11)
cmpwi r12, 0
bne mtFireXDone
cmpwi r7, 0
beq mtFireXDone
lwz r12, 4(r11)
stw r12, 44(r11)
mtFireXDone:
; Blow. The chosen hand (mtMic+56: 16 = left, now; 88 = right) held to the mouth (close to the
; head point and not above it) counts as blowing into the microphone: mtMic+4 is 1 while it lasts
; (see the hooks below).
lis r11, mtMic@ha
addi r11, r11, mtMic@l
lwz r12, 0(r11)
cmpwi r12, 0
beq mtMicDone
li r7, 0
lwz r12, 56(r11)
add r12, r9, r12
lwz r0, 0(r12)
cmpwi r0, 0
beq mtMicCount
lfs f0, 16(r12)
lfs f1, 4(r9)
fsubs f0, f0, f1
lfs f1, 32(r12)
lfs f2, 8(r9)
fsubs f1, f1, f2
lfs f2, 48(r12)
lfs f3, 12(r9)
fsubs f2, f2, f3
lfs f3, 16(r11)
.int 0xFC011800 ; fcmpu cr0, f1, f3
bge mtMicCount
fmuls f0, f0, f0
fmuls f1, f1, f1
fadds f0, f0, f1
fmuls f2, f2, f2
fadds f0, f0, f2
lfs f3, 12(r11)
.int 0xFC001800 ; fcmpu cr0, f0, f3
bge mtMicCount
li r7, 1
mtMicCount:
lwz r12, 20(r11)
cmpwi r7, 0
beq mtMicDown
addi r12, r12, 1
lwz r7, 28(r11)
cmpw r12, r7
ble mtMicStore
mr r12, r7
b mtMicStore
mtMicDown:
cmpwi r12, 0
beq mtMicStore
addi r12, r12, -1
mtMicStore:
stw r12, 20(r11)
lwz r7, 24(r11)
cmpw r12, r7
li r7, 0
blt mtMicFlag
li r7, 1
mtMicFlag:
lwz r12, 4(r11)
cmpwi r12, 0
bne mtMicFlagStore
cmpwi r7, 0
beq mtMicFlagStore
lwz r12, 48(r11)
addi r12, r12, 1
stw r12, 48(r11)
mtMicFlagStore:
stw r7, 4(r11)
mtMicDone:
mr r0, r3
cmpwi r0, 16
blt mtMotionCount
li r0, 16
mtMotionCount:
mulli r0, r0, 0xAC
add r0, r0, r4
mr r11, r4
mtMotionNext:
cmpw r11, r0
bge mtMotionDone
lwz r12, 0(r11)
and r12, r12, r6
add r12, r12, r5
stw r12, 0(r11)
cmpwi r8, 0
beq mtMotionKeepLeft
stfs f4, 12(r11)
stfs f5, 16(r11)
mtMotionKeepLeft:
cmpwi r10, 0
beq mtMotionKeepRight
stfs f8, 20(r11)
stfs f9, 24(r11)
mtMotionKeepRight:
addi r11, r11, 0xAC
b mtMotionNext
mtMotionDone:
; B runs only: X is held by B alone when no other source (trigger, left X, the attack gesture) holds it
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
lwz r0, 12(r12)
cmpwi r0, 0
beq mtRunBNone
lwz r0, 16(r12)
cmpwi r0, 0
bne mtRunBNone
lwz r0, 0(r12)
b mtRunBStore
mtRunBNone:
li r0, 0
mtRunBStore:
stw r0, 4(r12)
lis r8, mtControl@ha
addi r8, r8, mtControl@l
lwz r7, 0(r4)
; Two configurable combinations, either of which switches. The test asks for
; all bits of a mask, so one mask is a single button or a chord; a mask of
; zero is switched off.
li r5, 0
lwz r9, 60(r8)
cmpwi r9, 0
beq mtToggleAlt
and r12, r7, r9
cmpw r12, r9
bne mtToggleAlt
li r5, 1
b mtToggleState
mtToggleAlt:
lwz r9, 64(r8)
cmpwi r9, 0
beq mtToggleState
and r12, r7, r9
cmpw r12, r9
bne mtToggleState
li r5, 1
mtToggleState:
mr r7, r5
lwz r9, 4(r8)
stw r7, 4(r8)
cmpwi r7, 0
beq mtInputMode
cmpw r7, r9
beq mtInputMode
; In first person the switch button first steps through the camera distances
; (mtEyeBackCtl) and only leaves first person after the last one. Stepping
; changes neither the mode nor the turning; leaving resets the distance.
lwz r7, 0(r8)
cmpwi r7, 1
bne mtToggleFlipMode
lis r9, mtEyeBackCtl@ha
addi r9, r9, mtEyeBackCtl@l
; mtControl+28 is 1 only while the first-person camera is really in use. In the
; intro and on the map the mode stays "first person" but the view is diorama, so
; there a press leaves at once, as before, instead of stepping unseen distances.
lwz r7, 28(r8)
cmpwi r7, 1
bne mtToggleLeave
lwz r10, 8(r9)
addi r10, r10, 1
cmpwi r10, 2
bge mtToggleLeave
stw r10, 8(r9)
mulli r12, r10, 4
add r12, r12, r9
lwz r7, 12(r12)
lis r12, mtEyeBack@ha
stw r7, mtEyeBack@l(r12)
b mrLookInputDone
mtToggleLeave:
li r10, 0
stw r10, 8(r9)
lwz r7, 12(r9)
lis r12, mtEyeBack@ha
stw r7, mtEyeBack@l(r12)
mtToggleFlipMode:
lwz r7, 0(r8)
cmpwi r7, 0
li r7, 1
beq mtStoreMode
li r7, 0
mtStoreMode:
stw r7, 0(r8)
lwz r7, 8(r8)
addi r7, r7, 1
stw r7, 8(r8)
lis r9, mrLookCos@ha
addi r9, r9, mrLookCos@l
lis r7, 0x3F80
stw r7, 0(r9)
li r7, 0
stw r7, 4(r9)
stw r7, 8(r9)
b mrLookInputDone
mtInputMode:
lwz r7, 0(r8)
cmpwi r7, 1
bne mtMapYawInput
; Camera distance button: each press in first person steps mtEyeBack through
; the two values of mtEyeBackCtl. Same edge logic as the mode switch; a mask
; of zero switches the button off.
lis r9, mtEyeBackCtl@ha
addi r9, r9, mtEyeBackCtl@l
lwz r7, 0(r4)
lwz r12, 0(r9)
li r5, 0
cmpwi r12, 0
beq mtEyeBackState
and r10, r7, r12
cmpw r10, r12
bne mtEyeBackState
li r5, 1
mtEyeBackState:
lwz r10, 4(r9)
stw r5, 4(r9)
cmpwi r5, 0
beq mtEyeBackDone
cmpwi r10, 0
bne mtEyeBackDone
lwz r10, 8(r9)
addi r10, r10, 1
cmpwi r10, 2
blt mtEyeBackStore
li r10, 0
mtEyeBackStore:
stw r10, 8(r9)
mulli r12, r10, 4
add r12, r12, r9
lwz r7, 12(r12)
lis r12, mtEyeBack@ha
stw r7, mtEyeBack@l(r12)
mtEyeBackDone:
; Hand calibration: grip L + Minus steps the left glove's orientation preset, grip R + Minus the right's.
lis r9, mtHandCtl@ha
addi r9, r9, mtHandCtl@l
lwz r12, 32(r9)
cmpwi r12, 0
beq mtHandCalAllDone
lwz r7, 0(r4)
li r5, 0
andi. r12, r7, 36
cmpwi r12, 36
bne mtHandCalL0
andi. r12, r7, 16
bne mtHandCalL0
li r5, 1
mtHandCalL0:
cmpwi r5, 0
bne mtHandCalLHeld
li r10, 0
stw r10, 24(r9)
b mtHandCalLDone
mtHandCalLHeld:
lwz r10, 24(r9)
li r12, -1
cmpw r10, r12
beq mtHandCalLDone
addi r10, r10, 1
stw r10, 24(r9)
lwz r12, 80(r9)
cmpw r10, r12
blt mtHandCalLDone
li r12, -1
stw r12, 24(r9)
lwz r12, 64(r9)
mulli r12, r12, 52
add r12, r12, r9
lwz r10, 16(r12)
addi r10, r10, 1
cmpwi r10, 24
blt mtHandCalLStore
li r10, 0
mtHandCalLStore:
stw r10, 16(r12)
mtHandCalLDone:

li r5, 0
andi. r12, r7, 20
cmpwi r12, 20
bne mtHandCalR0
andi. r12, r7, 32
bne mtHandCalR0
li r5, 1
mtHandCalR0:
cmpwi r5, 0
bne mtHandCalRHeld
li r10, 0
stw r10, 28(r9)
b mtHandCalRDone
mtHandCalRHeld:
lwz r10, 28(r9)
li r12, -1
cmpw r10, r12
beq mtHandCalRDone
addi r10, r10, 1
stw r10, 28(r9)
lwz r12, 80(r9)
cmpw r10, r12
blt mtHandCalRDone
li r12, -1
stw r12, 28(r9)
lwz r12, 64(r9)
mulli r12, r12, 52
add r12, r12, r9
lwz r10, 20(r12)
addi r10, r10, 1
cmpwi r10, 24
blt mtHandCalRStore
li r10, 0
mtHandCalRStore:
stw r10, 20(r12)
mtHandCalRDone:

mtHandCalAllDone:
; SceneClass is cleared before calc, including the input poll. Use the last
; actual camera selection, which survives that boundary and rejects fallback.
lwz r7, 28(r8)
cmpwi r7, 1
bne mrLookInputDone
mtDistStick:
; Camera behind Mario (mtEyeBack above 0): the right stick's up-down moves it - pulled back the
; camera goes farther back, pushed forward it comes closer - between mtZoom+8 and +12.
lis r12, mtZoom@ha
addi r12, r12, mtZoom@l
lwz r7, 0(r12)
cmpwi r7, 0
beq mtDistDone
lis r11, mtEyeBack@ha
lwz r7, mtEyeBack@l(r11)
cmpwi r7, 0
bne mtDistBehind
; Original first person: the same stick pulls the view back by up to mtFpBackMax without leaving
; first person (the body stays hidden, the gloves and the fireball keep following the controllers).
lfs f1, 0x18(r4)
.int 0xFC400A10 ; fabs f2, f1
lfs f3, 16(r12)
.int 0xFC021800 ; fcmpu cr0, f2, f3
blt mtDistDone
lis r11, mtFpBack@ha
lfs f0, mtFpBack@l(r11)
lfs f2, 4(r12)
fmuls f1, f1, f2
fsubs f0, f0, f1
fsubs f1, f1, f1
.int 0xFC000800 ; fcmpu cr0, f0, f1
bge mtFpBackMin
fmr f0, f1
mtFpBackMin:
lis r7, mtFpBackMax@ha
lfs f1, mtFpBackMax@l(r7)
.int 0xFC000800 ; fcmpu cr0, f0, f1
ble mtFpBackMaxOk
fmr f0, f1
mtFpBackMaxOk:
stfs f0, mtFpBack@l(r11)
b mtDistDone
mtDistBehind:
; put behind Mario automatically (a jump or a clear pipe, mtActLog+216): the right stick only turns,
; it does not move the camera
lis r7, mtActLog@ha
addi r7, r7, mtActLog@l
lwz r7, 216(r7)
cmpwi r7, 0
bne mtDistDone
lfs f0, mtEyeBack@l(r11)
lfs f1, 0x18(r4)
.int 0xFC400A10 ; fabs f2, f1
lfs f3, 16(r12)
.int 0xFC021800 ; fcmpu cr0, f2, f3
blt mtDistDone
lfs f2, 4(r12)
fmuls f1, f1, f2
fsubs f0, f0, f1
lfs f1, 8(r12)
.int 0xFC000800 ; fcmpu cr0, f0, f1
bge mtDistMin
fmr f0, f1
mtDistMin:
lfs f1, 12(r12)
.int 0xFC000800 ; fcmpu cr0, f0, f1
ble mtDistMax
fmr f0, f1
mtDistMax:
stfs f0, mtEyeBack@l(r11)
; remember it as the camera-behind-Mario distance, so that step comes back at this distance
lis r12, mtEyeBackCtl@ha
addi r12, r12, mtEyeBackCtl@l
stfs f0, 16(r12)
mtDistDone:
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f1, 0x14(r4)
.int 0xFC400A10 ; fabs f2, f1
lis r9, mrSnapSin@ha
addi r9, r9, mrSnapSin@l
lwz r7, 0(r9)
cmpwi r7, 0
beq mrLookNoReset
; Snap turning: re-arm once the stick is back below 0.3, fire once past 0.6.
lfs f0, 36(r8)
.int 0xFC020000 ; fcmpu cr0, f2, f0
bge mrSnapHigh
li r7, 0
stw r7, 8(r9)
b mrLookNoTurn
mrSnapHigh:
lwz r7, 8(r9)
cmpwi r7, 0
bne mrLookNoTurn
lfs f0, 12(r9)
.int 0xFC020000 ; fcmpu cr0, f2, f0
blt mrLookNoTurn
li r7, 1
stw r7, 8(r9)
lfs f3, 0(r9)
lfs f0, 28(r8)
.int 0xFC010000 ; fcmpu cr0, f1, f0
bge mrSnapRight
fneg f3, f3
mrSnapRight:
lfs f4, 0(r8)
lfs f5, 4(r8)
lfs f6, 4(r9)
fmuls f7, f4, f6
fmuls f8, f5, f3
fsubs f7, f7, f8
fmuls f9, f5, f6
fmuls f10, f4, f3
fadds f9, f9, f10
stfs f7, 0(r8)
stfs f9, 4(r8)
; a snap turn: for a few steps the player's own shapes are not drawn (arm and glove would show at different places, mtPipeEye+36)
lis r7, mtPipeEye@ha
addi r7, r7, mtPipeEye@l
li r9, 0x3F
stw r9, 36(r7)
b mrLookNoTurn
mrLookNoReset:
lfs f0, 16(r8)
.int 0xFC020000 ; fcmpu cr0, f2, f0
blt mrLookNoTurn
lfs f0, 12(r8)
fmuls f1, f1, f2
fmuls f1, f1, f0
lfs f4, 0(r8)
lfs f5, 4(r8)
fmuls f6, f1, f1
lfs f7, 24(r8)
fmuls f6, f6, f7
lfs f7, 20(r8)
fsubs f6, f7, f6
fmuls f7, f4, f6
fmuls f8, f5, f1
fsubs f7, f7, f8
fmuls f9, f5, f6
fmuls f10, f4, f1
fadds f9, f9, f10
stfs f7, 0(r8)
stfs f9, 4(r8)
mrLookNoTurn:
lfs f4, 0(r8)
lfs f5, 4(r8)
lfs f0, 28(r8)
mr r10, r3
cmpwi r10, 16
ble mrLookSample
li r10, 16
mrLookSample:
mr r11, r4
li r9, 0
mrLookNext:
cmpw r9, r10
bge mrLookInputDone
lfs f1, 0x0C(r11)
lfs f2, 0x10(r11)
fmuls f6, f1, f4
fmuls f7, f2, f5
fadds f6, f6, f7
fmuls f8, f2, f4
fmuls f10, f1, f5
fsubs f8, f8, f10
stfs f6, 0x0C(r11)
stfs f8, 0x10(r11)
stfs f0, 0x14(r11)
stfs f0, 0x18(r11)
addi r11, r11, 0xAC
addi r9, r9, 1
b mrLookNext
b mrLookInputDone
; The world map (diorama view, not the stage scene): the game turns its camera only 45 degrees each
; way there. mtMapYaw+0 = 1: the right stick's left-right turns the view instead, freely, round what
; the camera looks at (mtDioramaMath), and the left stick is turned the same way so Mario still walks
; where you push; the game gets no left-right on the right stick. mtMapYaw+16/+20 = cos/sin of the
; turn, eased per pad read by mtMapYaw+8 (radians at full tilt) past the dead zone +12.
mtMapYawInput:
lis r12, mtMapYaw@ha
addi r12, r12, mtMapYaw@l
lwz r0, 0(r12)
cmpwi r0, 0
beq mrLookInputDone
lis r11, mrSceneClass@ha
lwz r11, mrSceneClass@l(r11)
cmpwi r11, 0
beq mrLookInputDone
lis r0, 0x1032
ori r0, r0, 0x86DC
cmpw r11, r0
beq mrLookInputDone
lfs f1, 0x14(r4)
.int 0xFC400A10 ; fabs f2, f1
lfs f0, 12(r12)
.int 0xFC020000 ; fcmpu cr0, f2, f0
blt mtMapYawTurnDone
; d = -x * speed; (c, s) turned by d: c' = c(1 - d^2/2) - s d, s' = s(1 - d^2/2) + c d, back to length 1
lfs f0, 8(r12)
fmuls f1, f1, f0
fneg f1, f1
fmuls f2, f1, f1
lfs f0, 24(r12)
fmuls f2, f2, f0
lfs f0, 28(r12)
fsubs f2, f0, f2
lfs f3, 16(r12)
lfs f4, 20(r12)
fmuls f5, f3, f2
fmuls f6, f4, f1
fsubs f5, f5, f6
fmuls f6, f4, f2
fmuls f7, f3, f1
fadds f6, f6, f7
fmuls f2, f5, f5
fmuls f7, f6, f6
fadds f2, f2, f7
lfs f0, 24(r12)
fmuls f2, f2, f0
lfs f0, 32(r12)
fsubs f2, f0, f2
fmuls f5, f5, f2
fmuls f6, f6, f2
stfs f5, 16(r12)
stfs f6, 20(r12)
li r0, 0
stw r0, 0x14(r4)
mtMapYawTurnDone:
; the left stick in the turned view: x' = x c - y s, y' = x s + y c
lfs f3, 16(r12)
lfs f4, 20(r12)
lfs f1, 0x0C(r4)
lfs f2, 0x10(r4)
fmuls f5, f1, f3
fmuls f6, f2, f4
fsubs f5, f5, f6
fmuls f6, f1, f4
fmuls f7, f2, f3
fadds f6, f6, f7
stfs f5, 0x0C(r4)
stfs f6, 0x10(r4)
mrLookInputDone:
; diagnostics: what the game gets from the first pad read (sticks, buttons) and the camera mode
lis r12, mtActLog@ha
addi r12, r12, mtActLog@l
lwz r11, 0x0C(r4)
stw r11, 228(r12)
lwz r11, 0x10(r4)
stw r11, 232(r12)
lwz r11, 0x14(r4)
stw r11, 236(r12)
lwz r11, 0x18(r4)
stw r11, 240(r12)
lwz r11, 0(r4)
stw r11, 244(r12)
lis r11, mtControl@ha
addi r11, r11, mtControl@l
lwz r0, 0(r11)
stw r0, 248(r12)
lwz r0, 28(r11)
stw r0, 252(r12)
lwz r0, 0x34(r1)
mtlr r0
addi r1, r1, 0x30
blr
0x0236CA4C = bla mrLookInput
0x0236AC84 = bla mtRunGate

rrProjectionHeader:
.int 0x4354504A
.int 1
rrProjectionHits:
.int 0
rrProjectionSource:
.int 0
rrProjectionVtable:
.int 0x10347B00
rrProjectionCopies:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0


rrProjectionHook:
stwu r1, -0x20(r1)
stw r0, 8(r1)
stw r10, 12(r1)
stw r11, 16(r1)
stw r12, 20(r1)
.int 0x7C000026 ; mfcr r0
stw r0, 24(r1)
cmpwi r21, 0
bne rrProjectionExit
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r10, 0(r12)
lwz r11, 4(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 88
lis r12, rrCamera0@ha
addi r12, r12, rrCamera0@l
add r12, r12, r11
cmpw r15, r12
bne rrProjectionExit
; Only the camera already accepted by the consumer may change projection.
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 0
beq rrProjectionExit
lis r11, rrSlot@ha
addi r11, r11, rrSlot@l
lwz r11, 0(r11)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 4
lis r0, rrCameraPoseSequence@ha
add r11, r11, r0
addi r11, r11, rrCameraPoseSequence@l
lwz r0, 0(r11)
lwz r11, 0(r12)
cmpw r0, r11
bne rrProjectionExit
; Verify concrete perspective object class before copying its complete object.
lwz r11, 144(r16)
lis r10, rrProjectionVtable@ha
addi r10, r10, rrProjectionVtable@l
lwz r0, 0(r10)
cmpw r11, r0
bne rrProjectionExit
lis r10, rrEye@ha
addi r10, r10, rrEye@l
lwz r10, 0(r10)
addi r12, r12, 100
cmpwi r10, 1
beq rrProjectionEyeReady
addi r12, r12, 32
rrProjectionEyeReady:
lis r11, rrSlot@ha
addi r11, r11, rrSlot@l
lwz r11, 0(r11)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 184
lis r10, rrProjectionCopies@ha
addi r10, r10, rrProjectionCopies@l
add r10, r10, r11
lis r11, rrProjectionSource@ha
addi r11, r11, rrProjectionSource@l
stw r16, 0(r11)
lwz r11, 0(r16)
stw r11, 0(r10)
lwz r11, 4(r16)
stw r11, 4(r10)
lwz r11, 8(r16)
stw r11, 8(r10)
lwz r11, 12(r16)
stw r11, 12(r10)
lwz r11, 16(r16)
stw r11, 16(r10)
lwz r11, 20(r16)
stw r11, 20(r10)
lwz r11, 24(r16)
stw r11, 24(r10)
lwz r11, 28(r16)
stw r11, 28(r10)
lwz r11, 32(r16)
stw r11, 32(r10)
lwz r11, 36(r16)
stw r11, 36(r10)
lwz r11, 40(r16)
stw r11, 40(r10)
lwz r11, 44(r16)
stw r11, 44(r10)
lwz r11, 48(r16)
stw r11, 48(r10)
lwz r11, 52(r16)
stw r11, 52(r10)
lwz r11, 56(r16)
stw r11, 56(r10)
lwz r11, 60(r16)
stw r11, 60(r10)
lwz r11, 64(r16)
stw r11, 64(r10)
lwz r11, 68(r16)
stw r11, 68(r10)
lwz r11, 72(r16)
stw r11, 72(r10)
lwz r11, 76(r16)
stw r11, 76(r10)
lwz r11, 80(r16)
stw r11, 80(r10)
lwz r11, 84(r16)
stw r11, 84(r10)
lwz r11, 88(r16)
stw r11, 88(r10)
lwz r11, 92(r16)
stw r11, 92(r10)
lwz r11, 96(r16)
stw r11, 96(r10)
lwz r11, 100(r16)
stw r11, 100(r10)
lwz r11, 104(r16)
stw r11, 104(r10)
lwz r11, 108(r16)
stw r11, 108(r10)
lwz r11, 112(r16)
stw r11, 112(r10)
lwz r11, 116(r16)
stw r11, 116(r10)
lwz r11, 120(r16)
stw r11, 120(r10)
lwz r11, 124(r16)
stw r11, 124(r10)
lwz r11, 128(r16)
stw r11, 128(r10)
lwz r11, 132(r16)
stw r11, 132(r10)
lwz r11, 136(r16)
stw r11, 136(r10)
lwz r11, 140(r16)
stw r11, 140(r10)
lwz r11, 144(r16)
stw r11, 144(r10)
lwz r11, 148(r16)
stw r11, 148(r10)
lwz r11, 152(r16)
stw r11, 152(r10)
lwz r11, 156(r16)
stw r11, 156(r10)
lwz r11, 160(r16)
stw r11, 160(r10)
lwz r11, 164(r16)
stw r11, 164(r10)
lwz r11, 168(r16)
stw r11, 168(r10)
lwz r11, 172(r16)
stw r11, 172(r10)
lwz r11, 176(r16)
stw r11, 176(r10)
lwz r11, 180(r16)
stw r11, 180(r10)
lwz r11, 0(r12)
stw r11, 168(r10)
lwz r11, 4(r12)
stw r11, 172(r10)
lwz r11, 8(r12)
stw r11, 176(r10)
lwz r11, 12(r12)
stw r11, 180(r10)
lwz r11, 16(r12)
stw r11, 4(r10)
stw r11, 68(r10)
lwz r11, 20(r12)
stw r11, 12(r10)
stw r11, 76(r10)
lwz r11, 24(r12)
stw r11, 24(r10)
stw r11, 88(r10)
lwz r11, 28(r12)
stw r11, 28(r10)
stw r11, 92(r10)
lis r11, rrEye@ha
addi r11, r11, rrEye@l
lwz r11, 0(r11)
cmpwi r11, 1
beq rrScalarLeft
lwz r11, 52(r12)
stw r11, 156(r10)
lwz r11, 56(r12)
stw r11, 160(r10)
lwz r11, 60(r12)
stw r11, 164(r10)
b rrScalarDone
rrScalarLeft:
lwz r11, 72(r12)
stw r11, 156(r10)
lwz r11, 76(r12)
stw r11, 160(r10)
lwz r11, 80(r12)
stw r11, 164(r10)
rrScalarDone:
; Only the copied projection changes. Native source and far plane stay intact.
lis r11, rrSlot@ha
lwz r0, rrSlot@l(r11)
mulli r0, r0, 2
lis r11, rrEye@ha
lwz r12, rrEye@l(r11)
add r0, r0, r12
mulli r0, r0, 4
lis r11, mtNearState@ha
addi r11, r11, mtNearState@l
add r12, r11, r0
lwz r0, 0(r12)
cmpwi r0, 1
bne mtNearDone
lwz r0, 16(r11)
stw r0, 148(r10)

mtNearDone:
lwz r11, 0(r10)
andi. r11, r11, 65535
lis r0, 0x0101
add r11, r11, r0
stw r11, 0(r10)
mr r16, r10
lis r12, rrSlot@ha
addi r12, r12, rrSlot@l
lwz r11, 0(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r0, 0(r12)
lis r12, rrEye@ha
addi r12, r12, rrEye@l
lwz r10, 0(r12)
lwz r11, 4(r12)
mulli r11, r11, 2
add r11, r11, r10
mulli r11, r11, 4
lis r12, rrProjectionPoseSequence@ha
addi r12, r12, rrProjectionPoseSequence@l
add r12, r12, r11
stw r0, 0(r12)
lis r12, rrProjectionHits@ha
addi r12, r12, rrProjectionHits@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
rrProjectionExit:
lwz r0, 24(r1)
.int 0x7C0FF120 ; mtcrf 255, r0
lwz r0, 8(r1)
lwz r10, 12(r1)
lwz r11, 16(r1)
lwz r12, 20(r1)
addi r1, r1, 0x20
blr

rrPoseMarkerMagic:
.int 0x3E400000
.int 0x3F500000
rrCameraPoseSequence:
.int 0
.int 0
.int 0
.int 0
rrProjectionPoseSequence:
.int 0
.int 0
.int 0
.int 0

rrMenuCameraUsed:
.int 0
.int 0
.int 0
.int 0
rrMenuMetadataMagic:
.int 0x3E600000

0x026EA584 = rrShadowSecondOriginal0:
rrShadowSecondSkip0:
lis r12, rrSecondRecord@ha
lwz r11, rrSecondRecord@l(r12)
cmpwi r11, 1
bne rrShadowSecondGo0
lis r12, rrShadowBothEyes@ha
lwz r11, rrShadowBothEyes@l(r12)
cmpwi r11, 0
beqlr
rrShadowSecondGo0:
b rrShadowSecondOriginal0
0x02451098 = bla rrShadowSecondSkip0

0x026EA584 = rrShadowSecondOriginal1:
rrShadowSecondSkip1:
lis r12, rrSecondRecord@ha
lwz r11, rrSecondRecord@l(r12)
cmpwi r11, 1
bne rrShadowSecondGo1
lis r12, rrShadowBothEyes@ha
lwz r11, rrShadowBothEyes@l(r12)
cmpwi r11, 0
beqlr
rrShadowSecondGo1:
b rrShadowSecondOriginal1
0x02451158 = bla rrShadowSecondSkip1

0x026EA840 = rrShadowSecondOriginal2:
rrShadowSecondSkip2:
lis r12, rrSecondRecord@ha
lwz r11, rrSecondRecord@l(r12)
cmpwi r11, 1
bne rrShadowSecondGo2
lis r12, rrShadowBothEyes@ha
lwz r11, rrShadowBothEyes@l(r12)
cmpwi r11, 0
beqlr
rrShadowSecondGo2:
b rrShadowSecondOriginal2
0x02451198 = bla rrShadowSecondSkip2

0x0235A198 = bla rrCopyMarker

0x0235A1E8 = bla rrCopyMarker

0x0235A2C4 = bla rrCopyMarker

0x0235A324 = bla rrCopyMarker

0x0235A550 = bla rrCopyMarker

0x0235A698 = bla rrCopyMarker

0x02379030 = bla rrCopyMarker

0x02394FD8 = bla rrCopyMarker

0x02394FF8 = bla rrCopyMarker

mrStereoRender:
stwu r1, -0x100(r1)
stw r0, 8(r1)
mflr r0
stw r0, 12(r1)
.int 0x7C000026
stw r0, 16(r1)
stw r3, 20(r1)
stw r4, 24(r1)
stw r5, 28(r1)
stw r6, 32(r1)
stw r7, 36(r1)
stw r8, 40(r1)
stw r9, 44(r1)
stw r10, 48(r1)
stw r11, 52(r1)
stw r12, 56(r1)
stw r15, 60(r1)
stw r16, 64(r1)
stw r21, 68(r1)
stfd f0, 80(r1)
stfd f1, 88(r1)
stfd f2, 96(r1)
stfd f3, 104(r1)
stfd f4, 112(r1)
stfd f5, 120(r1)
stfd f6, 128(r1)
stfd f7, 136(r1)
stfd f8, 144(r1)
stfd f9, 152(r1)
stfd f10, 160(r1)
stfd f11, 168(r1)
stfd f12, 176(r1)
stfd f13, 184(r1)
li r11, 0
lis r12, mrActiveCamera@ha
stw r11, mrActiveCamera@l(r12)
cmpwi r27, 0
beq mrStereoRestore
cmpwi r31, 0
beq mrStereoRestore
lwz r11, 144(r31)
lis r12, 0x1034
addi r12, r12, 0x7B00
cmpw r11, r12
bne mrStereoRestore
mr r3, r27
mr r16, r31
bl rrCameraHook
mr r15, r3
li r21, 0
bl rrProjectionHook
cmpw r16, r31
beq mrStereoRestore
mr r27, r15
mr r31, r16
lis r12, mrActiveCamera@ha
stw r27, mrActiveCamera@l(r12)
mrStereoRestore:
lfd f0, 80(r1)
lfd f1, 88(r1)
lfd f2, 96(r1)
lfd f3, 104(r1)
lfd f4, 112(r1)
lfd f5, 120(r1)
lfd f6, 128(r1)
lfd f7, 136(r1)
lfd f8, 144(r1)
lfd f9, 152(r1)
lfd f10, 160(r1)
lfd f11, 168(r1)
lfd f12, 176(r1)
lfd f13, 184(r1)
lwz r3, 20(r1)
lwz r4, 24(r1)
lwz r5, 28(r1)
lwz r6, 32(r1)
lwz r7, 36(r1)
lwz r8, 40(r1)
lwz r9, 44(r1)
lwz r10, 48(r1)
lwz r11, 52(r1)
lwz r12, 56(r1)
lwz r15, 60(r1)
lwz r16, 64(r1)
lwz r21, 68(r1)
lwz r0, 16(r1)
.int 0x7C0FF120
lwz r0, 12(r1)
mtlr r0
lwz r0, 8(r1)
addi r1, r1, 0x100
lwz r3, 4(r24)
b mrNativeRender
0x022D7FC8 = mrNativeRender:
0x022D7FC4 = ba mrStereoRender

mrActiveCamera:
.int 0
mrShadowUpload:
stwu r1, -0x50(r1)
mflr r0
stw r0, 0x54(r1)
stw r3, 8(r1)
stw r4, 12(r1)
stw r5, 16(r1)
stw r6, 20(r1)
stw r7, 24(r1)
stw r8, 28(r1)
stw r9, 32(r1)
stw r10, 36(r1)
stw r11, 40(r1)
stw r12, 44(r1)
lis r12, mrActiveCamera@ha
lwz r12, mrActiveCamera@l(r12)
cmpwi r12, 0
beq mrShadowRestore
cmpw r5, r12
bne mrShadowRestore
lbz r11, 0x111(r3)
cmpwi r11, 0
beq mrShadowRestore
cmplwi r4, 2
li r11, 0
bge mrShadowInverse
mulli r11, r4, 48
mrShadowInverse:
addi r4, r3, 0xA4
add r4, r4, r11
mr r3, r5
bl mrInverseView
mrShadowRestore:
lwz r3, 8(r1)
lwz r4, 12(r1)
lwz r5, 16(r1)
lwz r6, 20(r1)
lwz r7, 24(r1)
lwz r8, 28(r1)
lwz r9, 32(r1)
lwz r10, 36(r1)
lwz r11, 40(r1)
lwz r12, 44(r1)
lwz r0, 0x54(r1)
mtlr r0
addi r1, r1, 0x50
stwu r1, -0x80(r1)
b mrShadowNative
0x026ADD2C = mrInverseView:
0x02450AFC = mrShadowNative:
0x02450AF8 = ba mrShadowUpload
0x022D77B0 = mr r29, r26
0x022D77C4 = mr r31, r26
0x022D77EC = mr r3, r26
0x022D72F4 = mr r19, r30
; The fourth read of the game's single camera in the same view-setup function (0x022D76EC):
; the three above already use the camera passed in (r26, the eye's camera once mrStereoRender
; has swapped it), but this one still took [[ctx+0x18]+0xC] and handed camera+0xB0 on to
; 0x022D7254 (r10 -> r31 there), which feeds the light pass. So the light pass got the centre
; camera's data while the rest of the view used the eye's: lamp light on a nearby wall showed
; up in one eye and not in the other. r12 is only used for "addi r10, r12, 0xb0" right after.
0x022D78FC = mr r12, r26

; Light pre-pass cache. The game keeps a per-view "cached" flag and, while it is
; set, skips the whole light pass and keeps using the light buffer left by an
; earlier frame. Fixed-camera stages - the small enclosed ones - stay cached, so
; an eye is lit with a light buffer made for the other eye or for an older head
; pose. 1 = report "not cached" so the light pass and its view data are rebuilt
; for every eye; 0 = the original behaviour.
mrLppNoCache:
.int 1
mrLppCacheCheck:
lis r12, mrLppNoCache@ha
lwz r12, mrLppNoCache@l(r12)
cmpwi r12, 0
beq mrLppCacheOriginal
li r3, 0
blr
mrLppCacheOriginal:
lwz r11, 0x10(r3)
b mrLppCacheContinue
0x023A55EC = mrLppCacheContinue:
0x023A55E8 = ba mrLppCacheCheck

; HUT2: binding calls, current slot0 buffer, HUD calls, four eye/slot records.
rrHudTargetData:
.int 0x48555432
.int 0
.int 0
.int 0
rrHudTargetRecords:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0

0x024ED554 = rrHudOriginalDraw:
rrHudTrackColor:
; Tail-call original binding with all argument registers unchanged.
cmpwi r4, 0
bne rrHudTrackExit
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
stw r3, 8(r12)
rrHudTrackExit:
b import.gx2.GX2SetColorBuffer
rrHudTrackDraw:
mflr r0
stwu r1, -0x40(r1)
stw r0, 0x44(r1)
stw r3, 0x30(r1)
li r0, 0
stw r0, 0x28(r1)
; r7 is actor; r3 is original layout argument. Do not alter either.
lwz r11, 0(r7)
lis r12, 0x102B
addi r12, r12, -14928
cmpw r11, r12
bne rrHudDrawPass
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r11, 12(r12)
addi r11, r11, 1
stw r11, 12(r12)
stw r11, 0x18(r1)
lis r10, rrSlot@ha
addi r10, r10, rrSlot@l
lwz r10, 0(r10)
andi. r10, r10, 1
add r10, r10, r10
lis r11, rrEye@ha
addi r11, r11, rrEye@l
lwz r11, 0(r11)
andi. r11, r11, 1
add r10, r10, r11
add r10, r10, r10
add r10, r10, r10
add r10, r10, r10
add r10, r10, r10
add r10, r10, r10
addi r10, r10, 16
add r10, r12, r10
; count, actor, layout, current buffer, binding serial, reserved*3.
lwz r11, 0(r10)
addi r11, r11, 1
stw r11, 0(r10)
stw r7, 4(r10)
stw r3, 8(r10)
lwz r11, 8(r12)
stw r11, 12(r10)
lwz r11, 4(r12)
stw r11, 16(r10)
lis r12, rrHudWorldAck@ha
addi r12, r12, rrHudWorldAck@l
lwz r11, 0(r12)
lis r10, 0x4855
addi r10, r10, 0x4132
cmpw r11, r10
bne rrHudDrawPass
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r3, 8(r12)
cmpwi r3, 0
beq rrHudDrawPass
lwz r11, 4(r3)
cmpwi r11, 1280
bne rrHudDrawPass
lwz r11, 8(r3)
cmpwi r11, 720
bne rrHudDrawPass
stw r3, 0x2c(r1)
li r0, 1
stw r0, 0x28(r1)
li r4, 0
bl rrHudEmit
rrHudDrawPass:
lwz r3, 0x30(r1)
bl rrHudOriginalDraw
lwz r0, 0x28(r1)
cmpwi r0, 0
beq rrHudWorldExit
lwz r3, 0x2c(r1)
li r4, 1
bl rrHudEmit
rrHudWorldExit:
lwz r0, 0x44(r1)
mtlr r0
addi r1, r1, 0x40
blr
rrHudValues:
.int 0x3e900000
.int 0x3f300000
.int 0x3e800000
.int 0x3f400000
.int 0x00000000
.int 0x3e800000
.int 0x3f000000
.int 0x3f400000
rrHudEmit:
lis r12, rrHudValues@ha
addi r12, r12, rrHudValues@l
lfs f1, 0(r12)
lfs f2, 4(r12)
cmpwi r4, 0
bne rrHudEmitEnd
lfs f3, 8(r12)
b rrHudEmitIndex
rrHudEmitEnd:
lfs f3, 12(r12)
rrHudEmitIndex:
lis r10, mrUiTitleGroup@ha
lwz r10, mrUiTitleGroup@l(r10)
cmpwi r10, 0
beq mrUiMarkerColorReady
lis r10, mrUiTitleColor@ha
lfs f1, mrUiTitleColor@l(r10)
mrUiMarkerColorReady:
lis r10, rrSlot@ha
addi r10, r10, rrSlot@l
lwz r10, 0(r10)
add r10, r10, r10
lis r11, rrEye@ha
addi r11, r11, rrEye@l
lwz r11, 0(r11)
add r10, r10, r11
add r10, r10, r10
add r10, r10, r10
add r12, r12, r10
lfs f4, 16(r12)
b import.gx2.GX2ClearColor


0x023598CC = bla rrHudTrackColor

0x02359CB0 = bla rrHudTrackColor

0x02379068 = bla rrHudTrackColor

0x02395480 = bla rrHudTrackColor

0x023954B8 = bla rrHudTrackColor

0x0261E37C = bla rrHudTrackColor

0x02620120 = bla rrHudTrackColor

0x026236DC = bla rrHudTrackColor

0x02628ED0 = bla rrHudTrackColor

0x026AED58 = bla rrHudTrackColor

mrUiActiveBuffer:
.int 0
mrUiTitleGroup:
.int 0
mrUiTitleColor:
.int 0x3EB00000
mrUiGroupBegin:
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
lis r12, mrUiActiveBuffer@ha
li r11, 0
stw r11, mrUiActiveBuffer@l(r12)
lis r12, mrUiTitleGroup@ha
stw r11, mrUiTitleGroup@l(r12)
lis r12, rrHudWorldAck@ha
lwz r11, rrHudWorldAck@l(r12)
lis r10, 0x4855
addi r10, r10, 0x4132
cmpw r11, r10
bne mrUiGroupBeginExit
; Pure menus already use the host's complete menu surface; do not remove them.
lis r12, rrSlot@ha
lwz r11, rrSlot@l(r12)
mulli r11, r11, 2
lis r12, rrEye@ha
lwz r10, rrEye@l(r12)
add r11, r11, r10
mulli r11, r11, 4
lis r12, rrMenuCameraUsed@ha
addi r12, r12, rrMenuCameraUsed@l
lwzx r11, r12, r11
cmpwi r11, 0
beq mrUiGroupBeginExit
lis r12, rrHudTargetData@ha
addi r12, r12, rrHudTargetData@l
lwz r3, 8(r12)
cmpwi r3, 0
beq mrUiGroupBeginExit
lwz r11, 4(r3)
cmpwi r11, 1280
bne mrUiGroupBeginExit
lwz r11, 8(r3)
cmpwi r11, 720
bne mrUiGroupBeginExit
lis r12, mrUiActiveBuffer@ha
stw r3, mrUiActiveBuffer@l(r12)
; Inspect the same visible actors as the native layout loop. TitleLogo is
; the verified 102AC5B0 class; unrelated scene HUDs retain the game profile.
bl mrUiClassify
li r4, 0
bl rrHudEmit
mrUiGroupBeginExit:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
lwz r0, 0xC(r31)
b mrUiGroupLoop
mrUiGroupEnd:
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
lis r12, mrUiActiveBuffer@ha
lwz r3, mrUiActiveBuffer@l(r12)
li r11, 0
stw r11, mrUiActiveBuffer@l(r12)
cmpwi r3, 0
beq mrUiGroupEndExit
li r4, 1
bl rrHudEmit
mrUiGroupEndExit:
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
lwz r29, 0xC(r1)
b mrUiGroupReturn
0x02465764 = ba mrUiGroupBegin
0x02465768 = mrUiGroupLoop:
0x024657A8 = ba mrUiGroupEnd
0x024657AC = mrUiGroupReturn:
mrUiClassify:
lwz r8, 0xC(r31)
cmpwi r8, 0
ble mrUiClassifyExit
lwz r9, 0x10(r31)
li r10, 0
mrUiClassifyLoop:
lwzx r11, r9, r10
lbz r12, 0x4C(r11)
cmpwi r12, 0
beq mrUiClassifyNext
lwz r11, 0(r11)
lis r12, 0x102B
addi r12, r12, -14928
cmpw r11, r12
bne mrUiClassifyNext
lis r12, mrUiTitleGroup@ha
li r11, 1
stw r11, mrUiTitleGroup@l(r12)
blr
mrUiClassifyNext:
addi r10, r10, 4
addi r8, r8, -1
cmpwi r8, 0
bgt mrUiClassifyLoop
mrUiClassifyExit:
blr

; MCUL v1: epoch/count/builds/tests/rescues/invalid/overflow/native-visible.
mrCullHeader:
.int 0x4D43554C
.int 1
mrCullEpoch:
.int 0
mrCullCount:
.int 0
mrCullBuilds:
.int 0
mrCullTests:
.int 0
mrCullRescues:
.int 0
mrCullInvalid:
.int 0
mrCullOverflow:
.int 0
mrCullNativeVisible:
.int 0
mrCullOne:
.int 0x3F800000
mrCullZero:
.int 0
mrCullEntries:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0

0x02430A8C = mrCullBuildNative:
0x02430B10 = mrCullTestContinue:
0x0243079C = bla mrCullBuild
0x02430B0C = ba mrCullTest

mrCullBuild:
stwu r1, -0x40(r1)
mflr r0
stw r0, 0x44(r1)
stw r3, 8(r1)
stw r4, 12(r1)
stw r5, 16(r1)
bl mrCullBuildNative
stw r3, 20(r1)
lwz r5, 16(r1)
; Matrix is perspective-object+0x44. Other projection classes stay native.
lwz r11, 76(r5)
lis r12, 0x1034
addi r12, r12, 0x7B00
cmpw r11, r12
bne mrCullBuildInvalid
lis r12, rrCameraEnabled@ha
lwz r11, rrCameraEnabled@l(r12)
cmpwi r11, 1
bne mrCullBuildInvalid
lis r12, rrSlot@ha
lwz r11, rrSlot@l(r12)
mulli r11, r11, 196
lis r12, rrPoseLatch0@ha
addi r12, r12, rrPoseLatch0@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 0
beq mrCullBuildInvalid
stw r12, 24(r1)
lis r8, mrCullCount@ha
lwz r10, mrCullCount@l(r8)
lis r6, mrCullEntries@ha
addi r6, r6, mrCullEntries@l
lwz r3, 8(r1)
li r7, 0
mrCullFindBuild:
cmpw r7, r10
beq mrCullNewEntry
lwz r11, 0(r6)
cmpw r11, r3
beq mrCullEntryReady
addi r6, r6, 312
addi r7, r7, 1
b mrCullFindBuild
mrCullNewEntry:
cmpwi r10, 8
bge mrCullBuildOverflow
addi r10, r10, 1
stw r10, mrCullCount@l(r8)
mrCullEntryReady:
stw r3, 0(r6)
lis r8, mrCullEpoch@ha
lwz r11, mrCullEpoch@l(r8)
stw r11, 4(r6)
lwz r3, 12(r1)
stw r3, 8(r6)
lwz r11, 0(r12)
stw r11, 12(r6)
addi r6, r6, 16
li r10, 0
mrCullBuildEye:
lwz r3, 12(r1)
lis r12, mtPoseEye@ha
addi r12, r12, mtPoseEye@l
mulli r11, r10, 48
add r12, r12, r11
mr r9, r6
lis r8, mrCullOne@ha
lfs f3, mrCullOne@l(r8)
lis r11, mtControl@ha
addi r11, r11, mtControl@l
lwz r11, 28(r11)
cmpwi r11, 1
bne mtCullDiorama
; the clear-pipe view (mtTube, see mrEyeKeep) is culled with the same turned camera
lis r11, mtTube@ha
addi r11, r11, mtTube@l
lwz r8, 52(r11)
cmpwi r8, 0
beq mtCullTubeNo
addi r3, r11, 64
mtCullTubeNo:
lfs f1, 0(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 0(r9)
lfs f1, 0(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 4(r9)
lfs f1, 0(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r9)
lfs f1, 0(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f4, 0(r8)
lfs f5, 8(r8)
lfs f1, 0(r9)
lfs f2, 8(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f7, f1, f5
fmuls f8, f2, f4
fadds f7, f7, f8
stfs f0, 0(r9)
stfs f7, 8(r9)
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f1, 0(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
.int 0xFC000050 ; fneg f0, f0
lfs f1, 12(r12)
fadds f0, f0, f1
stfs f0, 12(r9)
lfs f1, 16(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r9)
lfs f1, 16(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r9)
lfs f1, 16(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r9)
lfs f1, 16(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f4, 0(r8)
lfs f5, 8(r8)
lfs f1, 16(r9)
lfs f2, 24(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f7, f1, f5
fmuls f8, f2, f4
fadds f7, f7, f8
stfs f0, 16(r9)
stfs f7, 24(r9)
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f1, 16(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
.int 0xFC000050 ; fneg f0, f0
lfs f1, 28(r12)
fadds f0, f0, f1
stfs f0, 28(r9)
lfs f1, 32(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r9)
lfs f1, 32(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 36(r9)
lfs f1, 32(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r9)
lfs f1, 32(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lis r8, mrLookCos@ha
addi r8, r8, mrLookCos@l
lfs f4, 0(r8)
lfs f5, 8(r8)
lfs f1, 32(r9)
lfs f2, 40(r9)
fmuls f0, f1, f4
fmuls f6, f2, f5
fsubs f0, f0, f6
fmuls f7, f1, f5
fmuls f8, f2, f4
fadds f7, f7, f8
stfs f0, 32(r9)
stfs f7, 40(r9)
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f1, 32(r9)
lfs f2, 0(r8)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r9)
lfs f2, 4(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r9)
lfs f2, 8(r8)
fmuls f1, f1, f2
fadds f0, f0, f1
.int 0xFC000050 ; fneg f0, f0
lfs f1, 44(r12)
fadds f0, f0, f1
lis r8, mtEyeBack@ha
lfs f1, mtEyeBack@l(r8)
lwz r8, mtEyeBack@l(r8)
cmpwi r8, 0
bne mtViewBackSet2
lis r8, mtFpBack@ha
lfs f1, mtFpBack@l(r8)
; the camera's own offset (mtEyeFit+68, + = forward): the view moves level along where it looks,
; away from Mario's head (the body drawn under the view comes along)
lis r8, mtEyeFit@ha
addi r8, r8, mtEyeFit@l
lfs f2, 68(r8)
fsubs f1, f1, f2
mtViewBackSet2:
fsubs f0, f0, f1
stfs f0, 44(r9)
; The whole distance goes straight back (level) instead of along the view's slope - looking up would
; otherwise send the camera down into the ground, looking down up into the air - and the part beyond
; the basic distance (mtLift+0) also lifts it, by mtLift+4 per unit. At distance 0 nothing changes.
lis r8, mtLift@ha
addi r8, r8, mtLift@l
lfs f2, 0(r8)
fsubs f2, f1, f2
fsubs f7, f2, f2
.int 0xFC023800 ; fcmpu cr0, f2, f7
bge mtLiftUp2
fmr f8, f7
b mtLiftK2
mtLiftUp2:
fmr f8, f2
mtLiftK2:
lfs f6, 4(r8)
fmuls f8, f8, f6
lfs f9, 36(r9)
fmuls f9, f9, f1
fsubs f8, f8, f9
lfs f9, 4(r9)
fmuls f9, f9, f8
lfs f6, 12(r9)
fsubs f6, f6, f9
stfs f6, 12(r9)
lfs f9, 20(r9)
fmuls f9, f9, f8
lfs f6, 28(r9)
fsubs f6, f6, f9
stfs f6, 28(r9)
lfs f9, 36(r9)
fmuls f9, f9, f8
lfs f6, 44(r9)
fsubs f6, f6, f9
stfs f6, 44(r9)
mtLiftEnd2:
b mtCullComposed
mtCullDiorama:
; the world map turned by mtMapYaw: culled with the same turned camera (its copy, mtMapYaw+36)
lis r8, mtMapYaw@ha
addi r8, r8, mtMapYaw@l
lwz r0, 4(r8)
cmpwi r0, 0
beq mtCullMapYawNo
addi r3, r8, 36
mtCullMapYawNo:
lis r8, rrCameraMinusOne@ha
addi r8, r8, rrCameraMinusOne@l
lfs f4, 0(r8)
lfs f1, 52(r3)
lfs f2, 64(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 32(r3)
fmuls f1, f1, f2
fmuls f5, f1, f3
lfs f1, 56(r3)
lfs f2, 68(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lfs f1, 60(r3)
lfs f2, 72(r3)
fmuls f2, f2, f4
fadds f1, f1, f2
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f5, f5, f1
lis r8, rrDioramaAdvance@ha
addi r8, r8, rrDioramaAdvance@l
lfs f6, 0(r8)
fmuls f6, f6, f5
lfs f1, 0(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 0(r9)
lfs f1, 0(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 4(r9)
lfs f1, 0(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r9)
lfs f1, 0(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 4(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 12(r12)
fadds f0, f0, f1
stfs f0, 12(r9)
lfs f1, 16(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r9)
lfs f1, 16(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r9)
lfs f1, 16(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r9)
lfs f1, 16(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 20(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 24(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 28(r12)
fadds f0, f0, f1
stfs f0, 28(r9)
lfs f1, 32(r12)
lfs f2, 0(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 16(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 32(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r9)
lfs f1, 32(r12)
lfs f2, 4(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 20(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 36(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 36(r9)
lfs f1, 32(r12)
lfs f2, 8(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 24(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 40(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r9)
lfs f1, 32(r12)
lfs f2, 12(r3)
fmuls f1, f1, f2
fmuls f0, f1, f3
lfs f1, 36(r12)
lfs f2, 28(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
lfs f2, 44(r3)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 40(r12)
fmuls f1, f1, f6
fadds f0, f0, f1
lfs f1, 44(r12)
fadds f0, f0, f1
stfs f0, 44(r9)
mtCullComposed:

; Clip inequalities: w +/- x and w +/- y, including off-axis offsets.
lwz r12, 24(r1)
mulli r11, r10, 32
addi r12, r12, 116
add r12, r12, r11
lfs f7, 0(r12)
lfs f8, 4(r12)
lis r8, mrCullOne@ha
lfs f9, mrCullOne@l(r8)
fsubs f8, f8, f9
lfs f0, 0(r6)
lfs f1, 32(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 48(r6)
.int 0xFC000210 ; fabs f0, f0
.int 0xFD400090 ; fmr f10, f0
lfs f0, 4(r6)
lfs f1, 36(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 52(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 8(r6)
lfs f1, 40(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 56(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 12(r6)
lfs f1, 44(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 60(r6)
stfs f10, 64(r6)
lfs f7, 0(r12)
lfs f8, 4(r12)
.int 0xFCE03850 ; fneg f7, f7
.int 0xFD004050 ; fneg f8, f8
lis r8, mrCullOne@ha
lfs f9, mrCullOne@l(r8)
fsubs f8, f8, f9
lfs f0, 0(r6)
lfs f1, 32(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 68(r6)
.int 0xFC000210 ; fabs f0, f0
.int 0xFD400090 ; fmr f10, f0
lfs f0, 4(r6)
lfs f1, 36(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 72(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 8(r6)
lfs f1, 40(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 76(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 12(r6)
lfs f1, 44(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 80(r6)
stfs f10, 84(r6)
lfs f7, 8(r12)
lfs f8, 12(r12)
lis r8, mrCullOne@ha
lfs f9, mrCullOne@l(r8)
fsubs f8, f8, f9
lfs f0, 16(r6)
lfs f1, 32(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 88(r6)
.int 0xFC000210 ; fabs f0, f0
.int 0xFD400090 ; fmr f10, f0
lfs f0, 20(r6)
lfs f1, 36(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 92(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 24(r6)
lfs f1, 40(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 96(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 28(r6)
lfs f1, 44(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 100(r6)
stfs f10, 104(r6)
lfs f7, 8(r12)
lfs f8, 12(r12)
.int 0xFCE03850 ; fneg f7, f7
.int 0xFD004050 ; fneg f8, f8
lis r8, mrCullOne@ha
lfs f9, mrCullOne@l(r8)
fsubs f8, f8, f9
lfs f0, 16(r6)
lfs f1, 32(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 108(r6)
.int 0xFC000210 ; fabs f0, f0
.int 0xFD400090 ; fmr f10, f0
lfs f0, 20(r6)
lfs f1, 36(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 112(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 24(r6)
lfs f1, 40(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 116(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 28(r6)
lfs f1, 44(r6)
fmuls f0, f0, f7
fmuls f1, f1, f8
fadds f0, f0, f1
stfs f0, 120(r6)
stfs f10, 124(r6)
lfs f0, 32(r6)
.int 0xFC000050 ; fneg f0, f0
stfs f0, 128(r6)
.int 0xFC000210 ; fabs f0, f0
.int 0xFD400090 ; fmr f10, f0
lfs f0, 36(r6)
.int 0xFC000050 ; fneg f0, f0
stfs f0, 132(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 40(r6)
.int 0xFC000050 ; fneg f0, f0
stfs f0, 136(r6)
.int 0xFC000210 ; fabs f0, f0
fadds f10, f10, f0
lfs f0, 44(r6)
.int 0xFC000050 ; fneg f0, f0
stfs f0, 140(r6)
stfs f10, 144(r6)
addi r6, r6, 148
addi r10, r10, 1
cmpwi r10, 2
blt mrCullBuildEye
lis r12, mrCullBuilds@ha
lwz r11, mrCullBuilds@l(r12)
addi r11, r11, 1
stw r11, mrCullBuilds@l(r12)
b mrCullBuildExit
mrCullBuildOverflow:
lis r12, mrCullOverflow@ha
lwz r11, mrCullOverflow@l(r12)
addi r11, r11, 1
stw r11, mrCullOverflow@l(r12)
b mrCullBuildExit
mrCullBuildInvalid:
lis r12, mrCullInvalid@ha
lwz r11, mrCullInvalid@l(r12)
addi r11, r11, 1
stw r11, mrCullInvalid@l(r12)
mrCullBuildExit:
lwz r3, 20(r1)
lwz r0, 0x44(r1)
mtlr r0
addi r1, r1, 0x40
blr

mrCullTestOriginal:
stwu r1, -0x48(r1)
b mrCullTestContinue
mrCullTest:
stwu r1, -0x40(r1)
mflr r0
stw r0, 0x44(r1)
stw r3, 8(r1)
stw r4, 12(r1)
stfd f1, 16(r1)
stfd f2, 24(r1)
stfd f3, 32(r1)
bl mrCullTestOriginal
cmpwi r3, 0
beq mrCullTryEyes
lis r12, mrCullNativeVisible@ha
lwz r11, mrCullNativeVisible@l(r12)
addi r11, r11, 1
stw r11, mrCullNativeVisible@l(r12)
b mrCullTestExit
mrCullTryEyes:
; Block rescues during pfPipe-flagged actor draws (avoids Black01 bonus room enclosure).
lis r12, pfPipeState@ha
addi r12, r12, pfPipeState@l
lwz r11, 0(r12)
cmpwi r11, 0
beq pfPipeRescueAllowed
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
b mrCullTestExit
pfPipeRescueAllowed:
lis r12, mrCullTests@ha
lwz r11, mrCullTests@l(r12)
addi r11, r11, 1
stw r11, mrCullTests@l(r12)
lis r12, mrCullCount@ha
lwz r10, mrCullCount@l(r12)
lis r6, mrCullEntries@ha
addi r6, r6, mrCullEntries@l
lwz r8, 8(r1)
li r7, 0
mrCullFindTest:
cmpw r7, r10
beq mrCullTestExit
lwz r11, 0(r6)
cmpw r11, r8
beq mrCullTestEntry
addi r6, r6, 312
addi r7, r7, 1
b mrCullFindTest
mrCullTestEntry:
lfd f1, 16(r1)
lfd f2, 24(r1)
lfd f3, 32(r1)
; radius cap: an object with a bounding sphere bigger than mrCullCap (float, +0) is not rescued
lis r12, mrCullCap@ha
addi r12, r12, mrCullCap@l
lfs f10, 0(r12)
.int 0xFC015000 ; fcmpu cr0, f1, f10
ble mrCullCapOk
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
li r3, 0
b mrCullTestExit
mrCullCapOk:
lwz r4, 12(r1)
lfs f4, 0(r4)
lfs f5, 4(r4)
lfs f6, 8(r4)
addi r6, r6, 64
li r7, 0
mrCullTestEye:
mr r8, r6
li r9, 0
mrCullTestPlane:
lfs f7, 0(r8)
lfs f8, 4(r8)
lfs f9, 8(r8)
lfs f10, 12(r8)
fmuls f7, f7, f4
fmuls f8, f8, f5
fmuls f9, f9, f6
fadds f7, f7, f8
fadds f7, f7, f9
fadds f7, f7, f10
lfs f8, 16(r8)
fmuls f8, f8, f1
cmpwi r9, 4
beq mrCullTestDepth
.int 0xFD004050 ; fneg f8, f8
.int 0xFC074000 ; fcmpu cr0, f7, f8
blt mrCullNextEye
addi r8, r8, 20
addi r9, r9, 1
b mrCullTestPlane
mrCullTestDepth:
fsubs f9, f2, f8
.int 0xFC074800 ; fcmpu cr0, f7, f9
blt mrCullNextEye
lis r12, mrCullZero@ha
lfs f10, mrCullZero@l(r12)
.int 0xFC035000 ; fcmpu cr0, f3, f10
ble mrCullVisible
fadds f9, f3, f8
.int 0xFC074800 ; fcmpu cr0, f7, f9
bgt mrCullNextEye
mrCullVisible:
li r3, 1
lis r12, mrCullRescues@ha
lwz r11, mrCullRescues@l(r12)
addi r11, r11, 1
stw r11, mrCullRescues@l(r12)
; the radius of the rescued object: the biggest seen (high word of the double) and a log2 histogram, both in mrCullCap
stfd f1, 40(r1)
lwz r11, 40(r1)
lis r12, mrCullCap@ha
addi r12, r12, mrCullCap@l
lwz r10, 12(r12)
cmplw r11, r10
ble mrCullNoMax
stw r11, 12(r12)
mrCullNoMax:
lis r10, 0x3FF0
li r8, 0
mrCullBkLoop:
cmplw r11, r10
blt mrCullBkDone
lis r9, 0x10
add r10, r10, r9
addi r8, r8, 1
cmpwi r8, 15
blt mrCullBkLoop
mrCullBkDone:
mulli r9, r8, 4
add r9, r9, r12
lwz r10, 16(r9)
addi r10, r10, 1
stw r10, 16(r9)
b mrCullTestExit
mrCullNextEye:
addi r6, r6, 148
addi r7, r7, 1
cmpwi r7, 2
blt mrCullTestEye
li r3, 0
mrCullTestExit:
lwz r0, 0x44(r1)
mtlr r0
addi r1, r1, 0x40
blr

; mrCullCap: +0 radius cap of the rescue (a float, game units; 8192 since 02/10: the objects of radius 16000 that the rescue drew as black walls at the horizon, 1e12 = no cap), +4 unused, +8 objects refused by it, +12 the biggest rescued
; radius so far (the high word of the double), +16.. 16 counters: rescued objects with a radius in [2^(k-1), 2^k), k = 0..15 (15 = 16384
; and up). Read live with a memory probe; the cap can be written live to test it.
mrCullCap:
.int 0x46000000
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
rrDioramaDistance:
.int 0x3F266666
rrDioramaAdvance:
.int 0x3EB33333
; Cutscenes (the stage scene with a camera that is not following the player): mtCine is 1 while
; one is on; mtCineDist / mtCineAdv (floats, +4) replace the diorama distance factor (0.65) and
; advance factor (0.35) for them - keep the two adding up to 1; 0.65 / 0.35 = the normal camera.
mtCine:
.int 0
mtCineDist:
.int 0x3F4CCCCD
.int 0x3E4CCCCD
; mode, previous switch state, generation, anchored generation, centre xyz,
; effective mode, slot0 mode/generation, slot1 mode/generation, -0.5, 0.1, 1,
; the two switch combinations the player can choose in Cemu, and last the
; previous state of the controller switch, which has its own edge.
mtControl:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0xBF000000
.int 0x3DCCCCCD
.int 0x3F800000
.int $switchMain
.int $switchAlt
.int 0
mtPoseScratch:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
mtPoseEye:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0

; First-person player visibility: render-only, original predicate in diorama.
0x024E775C = mtHideNativeResume:
mtHideShape:
stwu r1, -0x20(r1)
stw r0, 8(r1)
.int 0x7C000026 ; mfcr r0
stw r0, 12(r1)
stw r7, 16(r1)
stw r8, 20(r1)
stw r12, 24(r1)
; a snap turn of the view has just happened (mtPipeEye+36 not 0): the arm is built one step late and points at the glove's old place for a moment (or the game's own arm shows), so none
; of the player's own shapes (body, arms, gloves: the captured models of mtHideModel) is drawn - checked before every other rule here, so it holds whatever they would say
lis r7, mtPipeEye@ha
addi r7, r7, mtPipeEye@l
lwz r0, 36(r7)
cmpwi r0, 0
beq mtSnapEarlyNo
lis r8, mtHideModel@ha
addi r8, r8, mtHideModel@l
lwz r12, 16(r8)
cmpwi r12, 0
ble mtSnapEarlyNo
cmplwi r12, 17
bgt mtSnapEarlyNo
addi r7, r8, 20
mtSnapEarlyLoop:
lwz r0, 0(r7)
cmpw r3, r0
beq mtHideDo
addi r7, r7, 4
addi r12, r12, -1
cmpwi r12, 0
bgt mtSnapEarlyLoop
mtSnapEarlyNo:
mflr r7
stw r7, 28(r1)
bl pfGate
lwz r7, 28(r1)
mtlr r7
cmpwi r3, 0
bne pfGatePassed
lwz r7, 16(r1)
lwz r8, 20(r1)
lwz r12, 24(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 255,r0
lwz r0, 8(r1)
addi r1, r1, 0x20
blr
pfGatePassed:
lis r7, mtControl@ha
addi r7, r7, mtControl@l
lwz r0, 0(r7)
cmpwi r0, 1
bne mtHidePass
; Require the effective FP mode of this exact copied camera/eye as well.
lis r7, rrSlot@ha
lwz r0, rrSlot@l(r7)
mulli r0, r0, 2
lis r7, rrEye@ha
lwz r12, rrEye@l(r7)
add r0, r0, r12
mulli r0, r0, 4
lis r7, mtNearState@ha
addi r7, r7, mtNearState@l
add r7, r7, r0
lwz r0, 0(r7)
cmpwi r0, 1
bne mtHidePass
lis r8, mtHideModel@ha
addi r8, r8, mtHideModel@l
; Reject an identity older than two scene calculation ticks, including
; across level changes. Unsigned subtraction also handles epoch wraparound.
lwz r12, 12(r8)
lwz r0, 4(r8)
subf r12, r0, r12
cmplwi r12, 2
bgt mtHidePass
lwz r12, 16(r8)
cmplwi r12, 17
bgt mtHidePass
cmpwi r12, 0
beq mtHidePass
addi r7, r8, 20
mtHideCompare:
lwz r0, 0(r7)
cmpw r3, r0
beq mtHideMatched
addi r7, r7, 4
addi r12, r12, -1
cmpwi r12, 0
bgt mtHideCompare
b mtHideBox
mtHideMatched:
; Camera distance 0 is the original first person: the parts stay hidden, and the body model's
; shapes set in mtFpBody are drawn while the view is pulled back no more than mtFpBody+4.
lis r7, mtEyeBack@ha
lwz r7, mtEyeBack@l(r7)
cmpwi r7, 0
bne mtHideMaskIndex
; the Bill Box suit is worn (mtPipeEye+24): none of the player's own shapes is drawn (no body, arms or gloves)
lis r7, mtPipeEye@ha
addi r7, r7, mtPipeEye@l
lwz r0, 24(r7)
cmpwi r0, 0
bgt mtHideDo
lwz r0, 20(r8)
cmpw r3, r0
bne mtHidePart
cmplwi r4, 31
bgt mtHideZero
lis r7, mtFpBody@ha
addi r7, r7, mtFpBody@l
lwz r12, 0(r7)
.int 0x7D8C2430 ; srw r12, r12, r4
andi. r12, r12, 1
beq mtHideZero
; both are non-negative floats, so they compare as integers
lwz r0, 4(r7)
lis r12, mtFpBack@ha
lwz r12, mtFpBack@l(r12)
cmpw r12, r0
bgt mtHideZero
b mtHidePass
mtHideMaskIndex:
; r12 counts the shapes left after this one, so the shape's index is the
; captured count minus r12. Bit <index> of mtHideMask keeps that shape hidden;
; a shape whose bit is clear is drawn as usual.
lwz r0, 16(r8)
subf r12, r12, r0
lis r7, mtHideMask@ha
lwz r7, mtHideMask@l(r7)
.int 0x7CE76430 ; srw r7, r7, r12
andi. r7, r7, 1
beq mtHidePass
mtHideDo:
lwz r12, 8(r8)
addi r12, r12, 1
stw r12, 8(r8)
lwz r7, 16(r1)
lwz r8, 20(r1)
lwz r12, 24(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 255,r0
lwz r0, 8(r1)
addi r1, r1, 0x20
li r3, 0
blr
mtHidePart:
; a part hanging from the body (skirt, tail) is drawn with the body
lis r7, mtFpBody@ha
addi r7, r7, mtFpBody@l
lwz r0, 0(r7)
cmpwi r0, 0
beq mtHideZero
lwz r0, 4(r7)
lis r12, mtFpBack@ha
lwz r12, mtFpBack@l(r12)
cmpw r12, r0
bgt mtHideZero
lwz r7, 0(r3)
lis r12, 0x1000
cmplw r7, r12
blt mtHideZero
lis r12, 0x5000
cmplw r7, r12
bge mtHideZero
andi. r0, r7, 3
bne mtHideZero
lwz r7, 0(r7)
lis r12, 0x1000
cmplw r7, r12
blt mtHideZero
lis r12, 0x5000
cmplw r7, r12
bge mtHideZero
andi. r0, r7, 3
bne mtHideZero
lwz r0, 4(r7)
add r7, r7, r0
addi r7, r7, 4
lis r12, 0x1000
cmplw r7, r12
blt mtHideZero
lis r12, 0x5000
cmplw r7, r12
bge mtHideZero
li r12, 48
mtNameH:
lbz r0, 0(r7)
cmpwi r0, 0
beq mtHideZero
cmpwi r0, 0x53
bne mtNameTH
lbz r0, 1(r7)
cmpwi r0, 0x6B
bne mtNameNextH
lbz r0, 2(r7)
cmpwi r0, 0x69
beq mtHidePass
b mtNameNextH
mtNameTH:
cmpwi r0, 0x54
bne mtNameNextH
lbz r0, 1(r7)
cmpwi r0, 0x61
bne mtNameNextH
lbz r0, 2(r7)
cmpwi r0, 0x69
beq mtHidePass
mtNameNextH:
addi r7, r7, 1
addi r12, r12, -1
cmpwi r12, 0
bgt mtNameH
b mtHideZero
; Original first person: everything stays hidden except a glove whose controller is tracked.
mtHideZero:
lis r7, mtHandCtl@ha
addi r7, r7, mtHandCtl@l
lwz r12, 0(r7)
cmpwi r12, 0
beq mtHideDo
lis r12, mtPad@ha
addi r12, r12, mtPad@l
lwz r0, 36(r7)
cmpw r3, r0
bne mtHideZeroR
lwz r0, 16(r12)
cmpwi r0, 1
bne mtHideDo
lwz r0, 68(r12)
b mtGlovePose
mtHideZeroR:
lwz r0, 40(r7)
cmpw r3, r0
bne mtHideDo
lwz r0, 88(r12)
cmpwi r0, 1
bne mtHideDo
lwz r0, 140(r12)
; A glove's pose follows its controller: each glove model holds 7 whole hand meshes (0 tight fist,
; 1 half-closed, 2 grip, 3 open, 4 flat, 5 fingers up, 6 relaxed) and the game shows one of them.
; Grip held -> mtGlovePoses+0 (the fist), trigger held -> +4 (half-closed); neither -> the game's own
; choice. r0 = the controller's buttons (16 trigger, 32 grip), r4 = the shape asked about.
mtGlovePose:
lis r8, mtGlovePoses@ha
addi r8, r8, mtGlovePoses@l
lwz r7, 8(r8)
cmpwi r7, 0
beq mtHidePass
andi. r7, r0, 32
lwz r7, 0(r8)
bne mtGloveForce
andi. r7, r0, 16
lwz r7, 4(r8)
bne mtGloveForce
lwz r7, 16(r8)
cmpwi r7, 0
blt mtHidePass
mtGloveForce:
lwz r12, 12(r8)
addi r12, r12, 1
stw r12, 12(r8)
cmpw r4, r7
bne mtHideDo
lwz r7, 16(r1)
lwz r8, 20(r1)
lwz r12, 24(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 255,r0
lwz r0, 8(r1)
addi r1, r1, 0x20
li r3, 1
blr
mtHidePass:
lwz r7, 16(r1)
lwz r8, 20(r1)
lwz r12, 24(r1)
lwz r0, 12(r1)
.int 0x7C0FF120 ; mtcrf 255,r0
lwz r0, 8(r1)
addi r1, r1, 0x20
lwz r11, 0(r3)
b mtHideNativeResume
; The Bill Box suit ("BoxKiller") the player wears, found by its position around the eye; only in the original first person (mtEyeBack 0).
; It is drawn as always; mtPipeEye+24 = 3 tells the eye code and the player-shape code that the suit is on (mtBoxHide: +0 on, +4 the horizontal distance (90),
; +8/+12 the box origin's height relative to the eye (-260 / 40), +16 the suit's skeleton while it is worn).
mtHideBox:
lis r12, mtEyeBack@ha
lwz r12, mtEyeBack@l(r12)
cmpwi r12, 0
bne mtHidePass
lwz r7, 36(r3)
lis r12, 0x1000
cmplw r7, r12
blt mtHidePass
lis r12, 0x5000
cmplw r7, r12
bge mtHidePass
lwz r8, 4(r7)
add r7, r7, r8
addi r7, r7, 4
lis r12, 0x1000
cmplw r7, r12
blt mtHidePass
lis r12, 0x5000
cmplw r7, r12
bge mtHidePass
lbz r0, 0(r7)
cmpwi r0, 66
bne mtHidePass
lbz r0, 1(r7)
cmpwi r0, 111
bne mtHidePass
lbz r0, 2(r7)
cmpwi r0, 120
bne mtHidePass
lbz r0, 3(r7)
cmpwi r0, 75
bne mtHidePass
lbz r0, 4(r7)
cmpwi r0, 105
bne mtHidePass
lbz r0, 5(r7)
cmpwi r0, 108
bne mtHidePass
lbz r0, 6(r7)
cmpwi r0, 108
bne mtHidePass
lbz r0, 7(r7)
cmpwi r0, 101
bne mtHidePass
lbz r0, 8(r7)
cmpwi r0, 114
bne mtHidePass
lbz r0, 9(r7)
cmpwi r0, 0
bne mtHidePass
lis r12, mtBoxHide@ha
addi r12, r12, mtBoxHide@l
lwz r0, 0(r12)
cmpwi r0, 0
beq mtHidePass
stwu r1, -0x20(r1)
stfd f8, 8(r1)
stfd f9, 16(r1)
stfd f10, 24(r1)
lis r7, mrEyeTarget@ha
addi r7, r7, mrEyeTarget@l
lfs f8, 0x90(r3)
lfs f9, 0(r7)
fsubs f8, f8, f9
.int 0xFD004210 ; fabs f8, f8
lfs f10, 4(r12)
.int 0xFC085000 ; fcmpu cr0, f8, f10
bge mtBoxSFarP
lfs f8, 0xB0(r3)
lfs f9, 8(r7)
fsubs f8, f8, f9
.int 0xFD004210 ; fabs f8, f8
.int 0xFC085000 ; fcmpu cr0, f8, f10
bge mtBoxSFarP
lfs f8, 0xA0(r3)
lfs f9, 4(r7)
fsubs f8, f8, f9
lfs f10, 8(r12)
.int 0xFC085000 ; fcmpu cr0, f8, f10
blt mtBoxSFarP
lfs f10, 12(r12)
.int 0xFC085000 ; fcmpu cr0, f8, f10
bgt mtBoxSFarP
lfd f8, 8(r1)
lfd f9, 16(r1)
lfd f10, 24(r1)
addi r1, r1, 0x20
b mtBoxSNear
mtBoxSFarP:
lfd f8, 8(r1)
lfd f9, 16(r1)
lfd f10, 24(r1)
addi r1, r1, 0x20
b mtBoxSFar
mtBoxSNear:
lis r12, mtBoxHide@ha
addi r12, r12, mtBoxHide@l
lis r8, mtPipeEye@ha
addi r8, r8, mtPipeEye@l
li r0, 3
stw r0, 24(r8)
; the suit's skeleton ([[model]+24], as for the player's parts), for the skinning step (mtPartTry)
lwz r8, 0(r3)
lis r0, 0x1000
cmplw r8, r0
blt mtBoxSFar
lis r0, 0x5000
cmplw r8, r0
bge mtBoxSFar
lwz r8, 24(r8)
stw r8, 16(r12)
mtBoxSFar:
b mtHidePass
mtBoxHide:
.int 1
.int 0x42B40000 ; 90.0
.int 0xC3820000 ; -260.0
.int 0x42200000 ; 40.0
.int 0 ; +16 the suit's skeleton while it is worn
0x024E7758 = ba mtHideShape

; First person body: the skeleton's skinning-matrix step (0x023DAD0C, r3 = skeleton, r4 = buffer
; index) builds the GPU matrices from the bones' world matrices. For the player's own body model in
; the original first person the world matrices are changed for that step only and put back straight
; after, so the face/eye parts, the shadow and the rest of the game still see the real ones:
; - turn (mtFpBody+12): every bone is turned about the vertical axis through the root so the body
;   faces the way the view has been turned with the right stick (the tracking space's forward,
;   not the head's own turning);
; - head (mtFpBody+8): the Head bone's (13 in every player body) rotation/scale part is zeroed, so
;   every vertex bound to the head (cap, hair, ears, face) collapses into the neck point.
0x023DAD10 = mtCalcBlockResume:
mtHeadWrap:
; Diagnostic (mtGlDbg): does this skeleton's root bone sit where the pack put a glove - this step's matrix or the previous one's?
lis r11, mtGlDbg@ha
addi r11, r11, mtGlDbg@l
lwz r9, 44(r11)
cmpwi r9, 0
beq mtGlDone
lwz r12, 16(r3)
lis r0, 0x1000
cmplw r12, r0
blt mtGlDone
lis r0, 0x5000
cmplw r12, r0
bge mtGlDone
andi. r0, r12, 3
bne mtGlDone
lwz r9, 40(r11)
addi r9, r9, 1
stw r9, 40(r11)
lfs f1, 12(r12)
lfs f2, 28(r12)
lfs f3, 44(r12)
lfs f7, 48(r11)
lis r10, mtHandW@ha
addi r10, r10, mtHandW@l
lfs f4, 12(r10)
lfs f5, 28(r10)
lfs f6, 44(r10)
fsubs f4, f4, f1
fsubs f5, f5, f2
fsubs f6, f6, f3
fmuls f4, f4, f4
fmuls f5, f5, f5
fmuls f6, f6, f6
fadds f4, f4, f5
fadds f4, f4, f6
.int 0xFC043800 ; fcmpu cr0, f4, f7
bge mtGlNoCL
lwz r9, 24(r11)
addi r9, r9, 1
stw r9, 24(r11)
lwz r9, 64(r11)
add r12, r11, r9
li r0, 48
stb r0, 68(r12)
addi r9, r9, 1
andi. r9, r9, 63
stw r9, 64(r11)
mtGlNoCL:
lfs f4, 0(r11)
lfs f5, 4(r11)
lfs f6, 8(r11)
fsubs f4, f4, f1
fsubs f5, f5, f2
fsubs f6, f6, f3
fmuls f4, f4, f4
fmuls f5, f5, f5
fmuls f6, f6, f6
fadds f4, f4, f5
fadds f4, f4, f6
.int 0xFC043800 ; fcmpu cr0, f4, f7
bge mtGlNoPL
lwz r9, 28(r11)
addi r9, r9, 1
stw r9, 28(r11)
mtGlNoPL:
lfs f4, 60(r10)
lfs f5, 76(r10)
lfs f6, 92(r10)
fsubs f4, f4, f1
fsubs f5, f5, f2
fsubs f6, f6, f3
fmuls f4, f4, f4
fmuls f5, f5, f5
fmuls f6, f6, f6
fadds f4, f4, f5
fadds f4, f4, f6
.int 0xFC043800 ; fcmpu cr0, f4, f7
bge mtGlNoCR
lwz r9, 32(r11)
addi r9, r9, 1
stw r9, 32(r11)
lwz r9, 64(r11)
add r12, r11, r9
li r0, 49
stb r0, 68(r12)
addi r9, r9, 1
andi. r9, r9, 63
stw r9, 64(r11)
mtGlNoCR:
lfs f4, 12(r11)
lfs f5, 16(r11)
lfs f6, 20(r11)
fsubs f4, f4, f1
fsubs f5, f5, f2
fsubs f6, f6, f3
fmuls f4, f4, f4
fmuls f5, f5, f5
fmuls f6, f6, f6
fadds f4, f4, f5
fadds f4, f4, f6
.int 0xFC043800 ; fcmpu cr0, f4, f7
bge mtGlNoPR
lwz r9, 36(r11)
addi r9, r9, 1
stw r9, 36(r11)
mtGlNoPR:
mtGlDone:
; Glove skeleton (mtGlFix): the glove is drawn with the matrix the arm ends at (mtHandW), whatever the game left in its own transform
lis r11, mtGlDbg@ha
addi r11, r11, mtGlDbg@l
lwz r0, 60(r11)
cmpwi r0, 0
beq mtGlFixDone
lis r10, mtHandCtl@ha
addi r10, r10, mtHandCtl@l
lwz r0, 0(r10)
cmpwi r0, 0
beq mtGlFixDone
lis r9, mtEyeBack@ha
lwz r0, mtEyeBack@l(r9)
cmpwi r0, 0
bne mtGlFixDone
lis r9, mtControl@ha
addi r9, r9, mtControl@l
lwz r0, 28(r9)
cmpwi r0, 1
bne mtGlFixDone
li r8, 0
mtGlFixHand:
mulli r6, r8, 4
add r6, r6, r10
lwz r9, 36(r6)
lis r0, 0x1000
cmplw r9, r0
blt mtGlFixNext
lis r0, 0x5000
cmplw r9, r0
bge mtGlFixNext
andi. r0, r9, 3
bne mtGlFixNext
lwz r9, 24(r9)
cmpw r9, r3
bne mtGlFixNext
lis r9, mtPad@ha
addi r9, r9, mtPad@l
li r7, 16
cmpwi r8, 0
beq mtGlFixTrk
li r7, 88
mtGlFixTrk:
lwzx r0, r9, r7
cmpwi r0, 1
bne mtGlFixNext
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
mulli r0, r8, 4
add r7, r9, r0
lwz r0, 96(r7)
cmpwi r0, 1
bne mtGlFixNext
lwz r12, 16(r3)
lis r0, 0x1000
cmplw r12, r0
blt mtGlFixNext
lis r0, 0x5000
cmplw r12, r0
bge mtGlFixNext
andi. r0, r12, 3
bne mtGlFixNext
lwz r7, 0(r3)
lis r0, 0x1000
cmplw r7, r0
blt mtGlFixNext
lis r0, 0x5000
cmplw r7, r0
bge mtGlFixNext
lwz r0, 8(r7)
lis r7, 0x0008
cmplw r0, r7
blt mtGlFixNext
lis r7, 0x0009
cmplw r0, r7
bge mtGlFixNext
mulli r0, r8, 48
add r9, r9, r0
li r7, 8
mtGlFixCopy:
lwz r0, 0(r9)
stw r0, 0(r12)
lwz r0, 4(r9)
stw r0, 4(r12)
lwz r0, 8(r9)
stw r0, 8(r12)
lwz r0, 12(r9)
stw r0, 12(r12)
lwz r0, 16(r9)
stw r0, 16(r12)
lwz r0, 20(r9)
stw r0, 20(r12)
lwz r0, 24(r9)
stw r0, 24(r12)
lwz r0, 28(r9)
stw r0, 28(r12)
lwz r0, 32(r9)
stw r0, 32(r12)
lwz r0, 36(r9)
stw r0, 36(r12)
lwz r0, 40(r9)
stw r0, 40(r12)
lwz r0, 44(r9)
stw r0, 44(r12)
addi r12, r12, 48
addi r7, r7, -1
cmpwi r7, 0
bgt mtGlFixCopy
mulli r0, r8, 4
add r9, r11, r0
lwz r7, 52(r9)
addi r7, r7, 1
stw r7, 52(r9)
mtGlFixNext:
addi r8, r8, 1
cmpwi r8, 2
blt mtGlFixHand
mtGlFixDone:
lis r12, mtControl@ha
lwz r0, mtControl@l(r12)
cmpwi r0, 1
bne mtHeadOrig
lis r12, mtEyeBack@ha
lwz r0, mtEyeBack@l(r12)
cmpwi r0, 0
bne mtHeadOrig
lis r12, mtNearState@ha
addi r12, r12, mtNearState@l
lwz r0, 0(r12)
cmpwi r0, 1
beq mtHeadFp
lwz r0, 4(r12)
cmpwi r0, 1
beq mtHeadFp
lwz r0, 8(r12)
cmpwi r0, 1
beq mtHeadFp
lwz r0, 12(r12)
cmpwi r0, 1
bne mtHeadOrig
mtHeadFp:
lis r12, mtFpBody@ha
addi r12, r12, mtFpBody@l
lwz r0, 0(r12)
cmpwi r0, 0
beq mtHeadOrig
lwz r0, 8(r12)
lwz r5, 12(r12)
add r0, r0, r5
lwz r5, 16(r12)
add r0, r0, r5
cmpwi r0, 0
beq mtHeadOrig
lwz r5, 4(r12)
lis r6, mtFpBack@ha
lwz r6, mtFpBack@l(r6)
cmpw r6, r5
bgt mtHeadOrig
lis r8, mtHideModel@ha
addi r8, r8, mtHideModel@l
lwz r0, 16(r8)
cmpwi r0, 0
beq mtHeadOrig
lwz r9, 20(r8)
lis r11, 0x1000
cmplw r9, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r9, r11
bge mtHeadOrig
andi. r0, r9, 3
bne mtHeadOrig
lwz r9, 0(r9)
lis r11, 0x1000
cmplw r9, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r9, r11
bge mtHeadOrig
andi. r0, r9, 3
bne mtHeadOrig
lwz r9, 24(r9)
cmpw r9, r3
bne mtPartTry
; a player body skeleton: exactly 22 bones (count in the high half of ResSkeleton+8)
lwz r10, 0(r3)
lis r11, 0x1000
cmplw r10, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r10, r11
bge mtHeadOrig
andi. r0, r10, 3
bne mtHeadOrig
lwz r0, 8(r10)
lis r11, 0x0016
cmplw r0, r11
blt mtHeadOrig
lis r11, 0x0017
cmplw r0, r11
bge mtHeadOrig
lwz r10, 16(r3)
lis r11, 0x1000
cmplw r10, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r10, r11
bge mtHeadOrig
andi. r0, r10, 3
bne mtHeadOrig
; eye height from this character's neck (mtEyeFit): Mario 145, Luigi ~153, Peach/Rosalina ~175,
; Toad ~84, small Mario ~76; eased so animation bobbing does not shake the view
lis r9, mtEyeFit@ha
addi r9, r9, mtEyeFit@l
; (off: Mario's 145, mtEyeFit+24); the menu's fine adjustment (+20) is added either way
; both modes follow the neck (the cat suit's bent pose, the Mega Mushroom's scale); +16 only decides whether the cap below applies
mtEyeFitNeck:
lfs f1, 652(r10)
lfs f2, 28(r10)
fsubs f1, f1, f2
; the model's own scale (length of the root's X column: 1 normally, several times that with the
; Mega Mushroom): the neck height is kept in unscaled units and scaled back at the end, so growing
; or shrinking moves the view at once
lfs f4, 0(r10)
lfs f5, 16(r10)
lfs f6, 32(r10)
fmuls f7, f4, f4
fmuls f5, f5, f5
fadds f7, f7, f5
fmuls f6, f6, f6
fadds f7, f7, f6
lfs f8, 40(r9)
lfs f2, 48(r9)
.int 0xFC071000 ; fcmpu cr0, f7, f2
blt mtEyeScaleDone
.int 0xFC803834 ; frsqrte f4, f7
lfs f5, 44(r9)
lfs f6, 52(r9)
fmuls f2, f4, f4
fmuls f2, f2, f7
fmuls f2, f2, f5
fsubs f2, f6, f2
fmuls f4, f4, f2
fmuls f2, f4, f4
fmuls f2, f2, f7
fmuls f2, f2, f5
fsubs f2, f6, f2
fmuls f4, f4, f2
fmuls f8, f7, f4
fmuls f1, f1, f4
stfs f8, 56(r9)
mtEyeScaleDone:
lwz r0, 32(r9)
cmpw r0, r3
beq mtEyePeakSame
stw r3, 32(r9)
b mtEyePeakStore
mtEyePeakSame:
lfs f2, 28(r9)
lfs f3, 36(r9)
fsubs f2, f2, f3
.int 0xFC011000 ; fcmpu cr0, f1, f2
bge mtEyePeakStore
fmr f1, f2
mtEyePeakStore:
stfs f1, 28(r9)
lfs f2, 0(r9)
fmuls f1, f1, f2
fmuls f1, f1, f8
; "Sempre a do Mario" (+16 = 0): a tall character sees from Mario's height at most (mtEyeFit+24 + the margin at +72, times the model's scale f8)
lwz r0, 16(r9)
cmpwi r0, 0
bne mtEyeCapDone
lfs f2, 24(r9)
lfs f3, 72(r9)
fadds f2, f2, f3
fmuls f2, f2, f8
.int 0xFC011000 ; fcmpu cr0, f1, f2
ble mtEyeCapDone
fmr f1, f2
mtEyeCapDone:
mtEyeFitAdd:
; two height profiles: a small character (eye height below mtEyeFit+60: small Mario...) gets the
; adjustment at +64, a big one the one at +20
lfs f2, 20(r9)
lfs f3, 60(r9)
.int 0xFC011800 ; fcmpu cr0, f1, f3
bge mtEyeFitBig
lfs f2, 64(r9)
mtEyeFitBig:
fadds f1, f1, f2
lfs f2, 8(r9)
.int 0xFC011000 ; fcmpu cr0, f1, f2
bge mtEyeFitMin
fmr f1, f2
mtEyeFitMin:
lfs f2, 12(r9)
.int 0xFC011000 ; fcmpu cr0, f1, f2
ble mtEyeFitMax
fmr f1, f2
mtEyeFitMax:
lis r7, mrEyeTarget@ha
addi r7, r7, mrEyeTarget@l
lfs f3, 12(r7)
fsubs f1, f1, f3
lfs f2, 4(r9)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 12(r7)
mtEyeFitDone:
lis r11, mtHeadSave@ha
addi r11, r11, mtHeadSave@l
stw r10, 36(r11)
li r0, 0
stw r0, 40(r11)
stw r0, 44(r11)
stw r0, 60(r11)
lis r7, mtTurnKeep@ha
addi r7, r7, mtTurnKeep@l
stw r0, 16(r7)
lwz r0, 12(r12)
cmpwi r0, 0
beq mtHeadNoTurn
lis r7, mtHandCam@ha
addi r7, r7, mtHandCam@l
lwz r0, 60(r7)
lwz r5, 64(r7)
add r0, r0, r5
cmpwi r0, 0
beq mtHeadNoTurn
; wanted forward (fx, fz) = the tracking space's forward -Z in the world; the body's forward
; (mx, mz) = the root bone's +Z; cos = m.f, sin = mz*fx - mx*fz, both scaled to unit length
lfs f1, 8(r7)
fneg f1, f1
lfs f2, 32(r7)
fneg f2, f2
; mtPipeEye+32: the heading of the body in the tracking space (mtBodyFollow, written by the layer) taken into the world by the 3x3 at r7 instead of the tracking forward
lis r8, mtPipeEye@ha
addi r8, r8, mtPipeEye@l
lwz r0, 32(r8)
cmpwi r0, 0
beq mtBFWorldDone
lis r8, mtBodyFollow@ha
addi r8, r8, mtBodyFollow@l
lfs f3, 0(r8)
lfs f4, 4(r8)
lfs f5, 0(r7)
fmuls f5, f5, f3
lfs f6, 8(r7)
fmuls f6, f6, f4
fadds f1, f5, f6
lfs f5, 24(r7)
fmuls f5, f5, f3
lfs f6, 32(r7)
fmuls f6, f6, f4
fadds f2, f5, f6
mtBFWorldDone:
lfs f3, 8(r10)
lfs f4, 40(r10)
fmuls f5, f3, f1
fmuls f6, f4, f2
fadds f5, f5, f6
fmuls f6, f4, f1
fmuls f7, f3, f2
fsubs f6, f6, f7
fmuls f7, f5, f5
fmuls f8, f6, f6
fadds f7, f7, f8
lfs f8, 48(r11)
.int 0xFC074000 ; fcmpu cr0, f7, f8
blt mtHeadNoTurn
; 1 / sqrt(x): the estimate, then two Newton steps
.int 0xFD003834 ; frsqrte f8, f7
lfs f11, 52(r11)
lfs f12, 56(r11)
fmuls f1, f8, f8
fmuls f1, f1, f7
fmuls f1, f1, f11
fsubs f1, f12, f1
fmuls f8, f8, f1
fmuls f1, f8, f8
fmuls f1, f1, f7
fmuls f1, f1, f11
fsubs f1, f12, f1
fmuls f8, f8, f1
fmuls f5, f5, f8
fmuls f6, f6, f8
lfs f9, 12(r10)
lfs f10, 44(r10)
; the body stands under the view (mtFpBody+24): its root goes to the eyes' spot on the ground, so
; pulling the view back with the stick (or stepping in the room) takes the body along
fmr f13, f9
fmr f0, f10
lwz r0, 24(r12)
cmpwi r0, 0
beq mtBodyEyeDone
lis r7, mtHandCam@ha
addi r7, r7, mtHandCam@l
lwz r0, 60(r7)
lwz r5, 64(r7)
cmpwi r0, 1
bne mtBodyEyeC1
cmpwi r5, 1
bne mtBodyEyeC0
lfs f13, 36(r7)
lfs f1, 48(r7)
fadds f13, f13, f1
lfs f0, 44(r7)
lfs f1, 56(r7)
fadds f0, f0, f1
lfs f1, 52(r11)
fmuls f13, f13, f1
fmuls f0, f0, f1
b mtBodyEyeHead
mtBodyEyeC0:
lfs f13, 36(r7)
lfs f0, 44(r7)
b mtBodyEyeHead
mtBodyEyeC1:
cmpwi r5, 1
bne mtBodyEyeDone
lfs f13, 48(r7)
lfs f0, 56(r7)
mtBodyEyeHead:
; the neck (Head bone 13) under the eyes, not the root: new root = eyes - turned (neck - root)
lfs f1, 636(r10)
fsubs f1, f1, f9
lfs f2, 668(r10)
fsubs f2, f2, f10
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
fsubs f13, f13, f3
fsubs f0, f0, f4
; mtFpBody+28: the view sits this far ahead of the body (+, the body moves back along the view's
; forward, so looking down does not clip into it) or behind it (-); game units
lfs f1, 28(r12)
lfs f2, 8(r7)
fmuls f2, f2, f1
fadds f13, f13, f2
lfs f2, 32(r7)
fmuls f2, f2, f1
fadds f0, f0, f2
mtBodyEyeDone:
lis r7, mtTurnKeep@ha
addi r7, r7, mtTurnKeep@l
stfs f5, 0(r7)
stfs f6, 4(r7)
stfs f9, 8(r7)
stfs f10, 12(r7)
stfs f13, 20(r7)
stfs f0, 24(r7)
li r0, 1
stw r0, 16(r7)
; stamped with the scene tick, so the shadow hooks stop using it once the body is not turned
lis r5, mtHideModel@ha
addi r5, r5, mtHideModel@l
lwz r5, 12(r5)
stw r5, 28(r7)
mr r5, r10
addi r6, r11, 64
li r7, 22
mtHeadTurnLoop:
lwz r0, 0(r5)
stw r0, 0(r6)
lwz r0, 32(r5)
stw r0, 16(r6)
lfs f1, 0(r5)
lfs f2, 32(r5)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
stfs f3, 0(r5)
stfs f4, 32(r5)
lwz r0, 4(r5)
stw r0, 4(r6)
lwz r0, 36(r5)
stw r0, 20(r6)
lfs f1, 4(r5)
lfs f2, 36(r5)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
stfs f3, 4(r5)
stfs f4, 36(r5)
lwz r0, 8(r5)
stw r0, 8(r6)
lwz r0, 40(r5)
stw r0, 24(r6)
lfs f1, 8(r5)
lfs f2, 40(r5)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
stfs f3, 8(r5)
stfs f4, 40(r5)
lwz r0, 12(r5)
stw r0, 12(r6)
lwz r0, 44(r5)
stw r0, 28(r6)
lfs f1, 12(r5)
lfs f2, 44(r5)
fsubs f1, f1, f9
fsubs f2, f2, f10
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
fadds f3, f3, f13
fadds f4, f4, f0
stfs f3, 12(r5)
stfs f4, 44(r5)
addi r5, r5, 48
addi r6, r6, 32
addi r7, r7, -1
cmpwi r7, 0
bgt mtHeadTurnLoop
li r0, 1
stw r0, 40(r11)
mtHeadNoTurn:
lwz r0, 8(r12)
cmpwi r0, 0
beq mtHeadNoHead
; world matrix of bone 13 (3x4 floats, 48 bytes each): keep its position, flatten its own
; X axis (the neck-to-top direction) to nothing and shrink the other two by mtFpBody+20, so
; the head becomes a small flat lid (the top of the cap) over the collar instead of a hole
addi r9, r10, 624
li r5, 0
lfs f13, 20(r12)
lwz r0, 0(r9)
stw r0, 0(r11)
lwz r0, 4(r9)
stw r0, 4(r11)
lwz r0, 8(r9)
stw r0, 8(r11)
lwz r0, 16(r9)
stw r0, 12(r11)
lwz r0, 20(r9)
stw r0, 16(r11)
lwz r0, 24(r9)
stw r0, 20(r11)
lwz r0, 32(r9)
stw r0, 24(r11)
lwz r0, 36(r9)
stw r0, 28(r11)
lwz r0, 40(r9)
stw r0, 32(r11)
stw r5, 0(r9)
lfs f1, 4(r9)
fmuls f1, f1, f13
stfs f1, 4(r9)
lfs f1, 8(r9)
fmuls f1, f1, f13
stfs f1, 8(r9)
stw r5, 16(r9)
lfs f1, 20(r9)
fmuls f1, f1, f13
stfs f1, 20(r9)
lfs f1, 24(r9)
fmuls f1, f1, f13
stfs f1, 24(r9)
stw r5, 32(r9)
lfs f1, 36(r9)
fmuls f1, f1, f13
stfs f1, 36(r9)
lfs f1, 40(r9)
fmuls f1, f1, f13
stfs f1, 40(r9)
li r0, 1
stw r0, 44(r11)
mtHeadNoHead:
; arms (mtFpBody+16): each arm reaches from the shoulder to its VR glove (the sleeve
; stretches along), or shrinks into the shoulder when that controller is not tracked
lwz r0, 16(r12)
cmpwi r0, 0
beq mtHeadCall
lis r7, mtArmSave@ha
addi r7, r7, mtArmSave@l
addi r9, r10, 720
lwz r0, 0(r9)
stw r0, 0(r7)
lwz r0, 4(r9)
stw r0, 4(r7)
lwz r0, 8(r9)
stw r0, 8(r7)
lwz r0, 12(r9)
stw r0, 12(r7)
lwz r0, 16(r9)
stw r0, 16(r7)
lwz r0, 20(r9)
stw r0, 20(r7)
lwz r0, 24(r9)
stw r0, 24(r7)
lwz r0, 28(r9)
stw r0, 28(r7)
lwz r0, 32(r9)
stw r0, 32(r7)
lwz r0, 36(r9)
stw r0, 36(r7)
lwz r0, 40(r9)
stw r0, 40(r7)
lwz r0, 44(r9)
stw r0, 44(r7)
addi r9, r10, 768
lwz r0, 0(r9)
stw r0, 48(r7)
lwz r0, 4(r9)
stw r0, 52(r7)
lwz r0, 8(r9)
stw r0, 56(r7)
lwz r0, 12(r9)
stw r0, 60(r7)
lwz r0, 16(r9)
stw r0, 64(r7)
lwz r0, 20(r9)
stw r0, 68(r7)
lwz r0, 24(r9)
stw r0, 72(r7)
lwz r0, 28(r9)
stw r0, 76(r7)
lwz r0, 32(r9)
stw r0, 80(r7)
lwz r0, 36(r9)
stw r0, 84(r7)
lwz r0, 40(r9)
stw r0, 88(r7)
lwz r0, 44(r9)
stw r0, 92(r7)
addi r9, r10, 816
lwz r0, 0(r9)
stw r0, 96(r7)
lwz r0, 4(r9)
stw r0, 100(r7)
lwz r0, 8(r9)
stw r0, 104(r7)
lwz r0, 12(r9)
stw r0, 108(r7)
lwz r0, 16(r9)
stw r0, 112(r7)
lwz r0, 20(r9)
stw r0, 116(r7)
lwz r0, 24(r9)
stw r0, 120(r7)
lwz r0, 28(r9)
stw r0, 124(r7)
lwz r0, 32(r9)
stw r0, 128(r7)
lwz r0, 36(r9)
stw r0, 132(r7)
lwz r0, 40(r9)
stw r0, 136(r7)
lwz r0, 44(r9)
stw r0, 140(r7)
addi r9, r10, 912
lwz r0, 0(r9)
stw r0, 144(r7)
lwz r0, 4(r9)
stw r0, 148(r7)
lwz r0, 8(r9)
stw r0, 152(r7)
lwz r0, 12(r9)
stw r0, 156(r7)
lwz r0, 16(r9)
stw r0, 160(r7)
lwz r0, 20(r9)
stw r0, 164(r7)
lwz r0, 24(r9)
stw r0, 168(r7)
lwz r0, 28(r9)
stw r0, 172(r7)
lwz r0, 32(r9)
stw r0, 176(r7)
lwz r0, 36(r9)
stw r0, 180(r7)
lwz r0, 40(r9)
stw r0, 184(r7)
lwz r0, 44(r9)
stw r0, 188(r7)
addi r9, r10, 960
lwz r0, 0(r9)
stw r0, 192(r7)
lwz r0, 4(r9)
stw r0, 196(r7)
lwz r0, 8(r9)
stw r0, 200(r7)
lwz r0, 12(r9)
stw r0, 204(r7)
lwz r0, 16(r9)
stw r0, 208(r7)
lwz r0, 20(r9)
stw r0, 212(r7)
lwz r0, 24(r9)
stw r0, 216(r7)
lwz r0, 28(r9)
stw r0, 220(r7)
lwz r0, 32(r9)
stw r0, 224(r7)
lwz r0, 36(r9)
stw r0, 228(r7)
lwz r0, 40(r9)
stw r0, 232(r7)
lwz r0, 44(r9)
stw r0, 236(r7)
addi r9, r10, 1008
lwz r0, 0(r9)
stw r0, 240(r7)
lwz r0, 4(r9)
stw r0, 244(r7)
lwz r0, 8(r9)
stw r0, 248(r7)
lwz r0, 12(r9)
stw r0, 252(r7)
lwz r0, 16(r9)
stw r0, 256(r7)
lwz r0, 20(r9)
stw r0, 260(r7)
lwz r0, 24(r9)
stw r0, 264(r7)
lwz r0, 28(r9)
stw r0, 268(r7)
lwz r0, 32(r9)
stw r0, 272(r7)
lwz r0, 36(r9)
stw r0, 276(r7)
lwz r0, 40(r9)
stw r0, 280(r7)
lwz r0, 44(r9)
stw r0, 284(r7)
li r0, 1
stw r0, 60(r11)
lis r8, mtArmTmp@ha
addi r8, r8, mtArmTmp@l
addi r5, r10, 720
lfs f9, 172(r8)
lfs f10, 180(r8)
; left arm: reach from the shoulder to the VR glove when it is tracked
lis r9, mtPad@ha
addi r9, r9, mtPad@l
lwz r0, 16(r9)
cmpwi r0, 1
bne mtArmFailL
lis r9, mtHandCtl@ha
addi r9, r9, mtHandCtl@l
lwz r0, 0(r9)
cmpwi r0, 0
beq mtArmFailL
lwz r6, 4(r9)
lis r9, 0x1000
cmplw r6, r9
blt mtArmFailL
lis r9, 0x5000
cmplw r6, r9
bge mtArmFailL
andi. r0, r6, 3
bne mtArmFailL
lwz r0, 12(r5)
stw r0, 0(r8)
lwz r0, 28(r5)
stw r0, 4(r8)
lwz r0, 44(r5)
stw r0, 8(r8)
lwz r0, 60(r5)
stw r0, 12(r8)
lwz r0, 76(r5)
stw r0, 16(r8)
lwz r0, 92(r5)
stw r0, 20(r8)
lwz r0, 108(r5)
stw r0, 24(r8)
lwz r0, 124(r5)
stw r0, 28(r8)
lwz r0, 140(r5)
stw r0, 32(r8)
; the glove's position: mtHandW, the newest matrix the pack gave the glove (the part's copy +0xB4 reached the arm a step late)
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
lwz r0, 96(r9)
cmpwi r0, 1
bne mtArmFailL
lwz r0, 12(r9)
stw r0, 36(r8)
lwz r0, 28(r9)
stw r0, 40(r8)
lwz r0, 44(r9)
stw r0, 44(r8)
lis r7, 0x0180
lwz r0, 152(r7)
cmpwi r0, 1
bne mtArmLeadNoL
lis r7, mtGlDbg@ha
addi r7, r7, mtGlDbg@l
lfs f1, 36(r8)
lfs f2, 0(r7)
fsubs f2, f1, f2
lfs f3, 40(r8)
lfs f4, 4(r7)
fsubs f4, f3, f4
lfs f5, 44(r8)
lfs f6, 8(r7)
fsubs f6, f5, f6
fmuls f7, f2, f2
fmuls f8, f4, f4
fadds f7, f7, f8
fmuls f8, f6, f6
fadds f7, f7, f8
lfs f8, 200(r8)
.int 0xFC074000 ; fcmpu cr0, f7, f8
bgt mtArmLeadNoL
lfs f7, 196(r8)
fmuls f2, f2, f7
fadds f1, f1, f2
stfs f1, 36(r8)
fmuls f4, f4, f7
fadds f3, f3, f4
stfs f3, 40(r8)
fmuls f6, f6, f7
fadds f5, f5, f6
stfs f5, 44(r8)
mtArmLeadNoL:
; the wrist (mtArmBend): the glove's place is kept, the arm is built toward a point behind it along the glove's finger axis
lfs f1, 36(r8)
stfs f1, 208(r8)
lfs f2, 40(r8)
stfs f2, 212(r8)
lfs f3, 44(r8)
stfs f3, 216(r8)
lwz r0, 232(r8)
cmpwi r0, 0
beq mtArmBendOffL
lfs f4, 8(r9)
lfs f5, 24(r9)
lfs f6, 40(r9)
fmuls f7, f4, f4
fmuls f8, f5, f5
fadds f7, f7, f8
fmuls f8, f6, f6
fadds f7, f7, f8
lfs f8, 164(r8)
fmuls f8, f8, f8
.int 0xFC074000 ; fcmpu cr0, f7, f8
blt mtArmBendOffL
.int 0xFD003834 ; frsqrte f8, f7
lfs f11, 52(r11)
lfs f12, 56(r11)
fmuls f13, f8, f8
fmuls f13, f13, f7
fmuls f13, f13, f11
fsubs f13, f12, f13
fmuls f8, f8, f13
fmuls f13, f8, f8
fmuls f13, f13, f7
fmuls f13, f13, f11
fsubs f13, f12, f13
fmuls f8, f8, f13
fmuls f4, f4, f8
fmuls f5, f5, f8
fmuls f6, f6, f8
stfs f4, 220(r8)
stfs f5, 224(r8)
stfs f6, 228(r8)
lfs f7, 204(r8)
fmuls f13, f4, f7
fsubs f1, f1, f13
stfs f1, 36(r8)
fmuls f13, f5, f7
fsubs f2, f2, f13
stfs f2, 40(r8)
fmuls f13, f6, f7
fsubs f3, f3, f13
stfs f3, 44(r8)
b mtArmBendDoneL
mtArmBendOffL:
li r0, 0
stw r0, 220(r8)
stw r0, 224(r8)
stw r0, 228(r8)
mtArmBendDoneL:
lfs f1, 192(r6)
lfs f2, 12(r9)
fsubs f1, f1, f2
fmuls f1, f1, f1
lfs f3, 208(r6)
lfs f4, 28(r9)
fsubs f3, f3, f4
fmuls f3, f3, f3
fadds f1, f1, f3
lfs f3, 224(r6)
lfs f4, 44(r9)
fsubs f3, f3, f4
fmuls f3, f3, f3
fadds f1, f1, f3
lis r7, mtGlDbg@ha
addi r7, r7, mtGlDbg@l
lfs f2, 48(r7)
.int 0xFC011000 ; fcmpu cr0, f1, f2
ble mtArmSameL
lwz r9, 188(r8)
addi r9, r9, 1
stw r9, 188(r8)
mtArmSameL:
lwz r9, 192(r8)
addi r9, r9, 1
stw r9, 192(r8)
lis r7, mtGlDbg@ha
addi r7, r7, mtGlDbg@l
lwz r9, 64(r7)
add r6, r7, r9
li r0, 32
stb r0, 68(r6)
addi r9, r9, 1
andi. r9, r9, 63
stw r9, 64(r7)
lfs f1, 12(r8)
lfs f2, 0(r8)
fsubs f1, f1, f2
stfs f1, 48(r8)
lfs f1, 16(r8)
lfs f2, 4(r8)
fsubs f1, f1, f2
stfs f1, 52(r8)
lfs f1, 20(r8)
lfs f2, 8(r8)
fsubs f1, f1, f2
stfs f1, 56(r8)
lfs f1, 48(r8)
lfs f2, 48(r8)
fmuls f3, f1, f2
lfs f1, 52(r8)
lfs f2, 52(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 56(r8)
lfs f2, 56(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailL
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 148(r8)
lfs f2, 132(r8)
fmuls f1, f1, f2
stfs f1, 120(r8)
lfs f1, 24(r8)
lfs f2, 12(r8)
fsubs f1, f1, f2
stfs f1, 48(r8)
lfs f1, 28(r8)
lfs f2, 16(r8)
fsubs f1, f1, f2
stfs f1, 52(r8)
lfs f1, 32(r8)
lfs f2, 20(r8)
fsubs f1, f1, f2
stfs f1, 56(r8)
lfs f1, 48(r8)
lfs f2, 48(r8)
fmuls f3, f1, f2
lfs f1, 52(r8)
lfs f2, 52(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 56(r8)
lfs f2, 56(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailL
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 148(r8)
lfs f2, 132(r8)
fmuls f1, f1, f2
stfs f1, 124(r8)
lfs f1, 36(r8)
lfs f2, 0(r8)
fsubs f1, f1, f2
stfs f1, 48(r8)
lfs f1, 40(r8)
lfs f2, 4(r8)
fsubs f1, f1, f2
stfs f1, 52(r8)
lfs f1, 44(r8)
lfs f2, 8(r8)
fsubs f1, f1, f2
stfs f1, 56(r8)
lfs f1, 48(r8)
lfs f2, 48(r8)
fmuls f3, f1, f2
lfs f1, 52(r8)
lfs f2, 52(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 56(r8)
lfs f2, 56(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailL
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 148(r8)
lfs f2, 132(r8)
fmuls f1, f1, f2
stfs f1, 128(r8)
lfs f4, 132(r8)
lfs f1, 48(r8)
fmuls f1, f1, f4
stfs f1, 60(r8)
lfs f1, 52(r8)
fmuls f1, f1, f4
stfs f1, 64(r8)
lfs f1, 56(r8)
fmuls f1, f1, f4
stfs f1, 68(r8)
lfs f1, 120(r8)
lfs f2, 124(r8)
fadds f1, f1, f2
stfs f1, 148(r8)
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 132(r8)
fmuls f1, f1, f1
lfs f2, 128(r8)
fmuls f1, f1, f2
lfs f2, 168(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
ble mtArmKL
fmr f1, f2
lwz r9, 184(r8)
addi r9, r9, 1
stw r9, 184(r8)
mtArmKL:
stfs f1, 136(r8)
; mtArmCanon: this arm's bind frame under the body's root (the animation is ignored), turned half a turn when the glove is on the far side
lfs f1, 60(r8)
lfs f2, 64(r8)
lfs f3, 68(r8)
lfs f4, 0(r10)
lfs f5, 16(r10)
lfs f6, 32(r10)
fmuls f4, f1, f4
fmuls f5, f2, f5
fadds f4, f4, f5
fmuls f6, f3, f6
fadds f4, f4, f6
fsubs f7, f7, f7
.int 0xFC043800 ; fcmpu cr0, f4, f7
blt mtArmCanonFlipL
lwz r0, 0(r10)
stw r0, 0(r5)
lwz r0, 16(r10)
stw r0, 16(r5)
lwz r0, 32(r10)
stw r0, 32(r5)
lwz r0, 4(r10)
stw r0, 4(r5)
lwz r0, 20(r10)
stw r0, 20(r5)
lwz r0, 36(r10)
stw r0, 36(r5)
lwz r0, 8(r10)
stw r0, 8(r5)
lwz r0, 24(r10)
stw r0, 24(r5)
lwz r0, 40(r10)
stw r0, 40(r5)
b mtArmCanonDoneL
mtArmCanonFlipL:
lfs f1, 0(r10)
fneg f1, f1
stfs f1, 0(r5)
lfs f1, 16(r10)
fneg f1, f1
stfs f1, 16(r5)
lfs f1, 32(r10)
fneg f1, f1
stfs f1, 32(r5)
lwz r0, 4(r10)
stw r0, 4(r5)
lwz r0, 20(r10)
stw r0, 20(r5)
lwz r0, 36(r10)
stw r0, 36(r5)
lfs f1, 8(r10)
fneg f1, f1
stfs f1, 8(r5)
lfs f1, 24(r10)
fneg f1, f1
stfs f1, 24(r5)
lfs f1, 40(r10)
fneg f1, f1
stfs f1, 40(r5)
mtArmCanonDoneL:
lwz r0, 0(r5)
stw r0, 72(r8)
lwz r0, 16(r5)
stw r0, 76(r8)
lwz r0, 32(r5)
stw r0, 80(r8)
lfs f1, 72(r8)
lfs f2, 72(r8)
fmuls f3, f1, f2
lfs f1, 76(r8)
lfs f2, 76(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 80(r8)
lfs f2, 80(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
fmuls f2, f2, f2
lfs f2, 164(r8)
fmuls f2, f2, f2
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailL
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f4, 132(r8)
lfs f1, 72(r8)
fmuls f1, f1, f4
stfs f1, 72(r8)
lfs f1, 76(r8)
fmuls f1, f1, f4
stfs f1, 76(r8)
lfs f1, 80(r8)
fmuls f1, f1, f4
stfs f1, 80(r8)
lfs f1, 72(r8)
lfs f2, 60(r8)
fmuls f3, f1, f2
lfs f1, 76(r8)
lfs f2, 64(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 80(r8)
lfs f2, 68(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 140(r8)
lfs f1, 72(r8)
lfs f2, 76(r8)
lfs f3, 80(r8)
lfs f4, 60(r8)
lfs f5, 64(r8)
lfs f6, 68(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 84(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 88(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 92(r8)
lfs f1, 140(r8)
lfs f2, 160(r8)
fadds f1, f1, f2
stfs f1, 148(r8)
lfs f2, 164(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailL
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 144(r8)
lfs f1, 144(r8)
fmuls f1, f1, f1
stfs f1, 144(r8)
lwz r0, 0(r5)
stw r0, 96(r8)
lwz r0, 16(r5)
stw r0, 100(r8)
lwz r0, 32(r5)
stw r0, 104(r8)
lfs f1, 84(r8)
lfs f2, 96(r8)
fmuls f3, f1, f2
lfs f1, 88(r8)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 92(r8)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 152(r8)
lfs f1, 84(r8)
lfs f2, 88(r8)
lfs f3, 92(r8)
lfs f4, 96(r8)
lfs f5, 100(r8)
lfs f6, 104(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 108(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 112(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 116(r8)
lfs f4, 140(r8)
lfs f5, 152(r8)
lfs f6, 144(r8)
fmuls f5, f5, f6
lfs f1, 96(r8)
fmuls f1, f1, f4
lfs f2, 108(r8)
fadds f1, f1, f2
lfs f2, 84(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
lfs f2, 136(r8)
fmuls f1, f1, f2
stfs f1, 0(r5)
stfs f1, 48(r5)
lfs f1, 100(r8)
fmuls f1, f1, f4
lfs f2, 112(r8)
fadds f1, f1, f2
lfs f2, 88(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
lfs f2, 136(r8)
fmuls f1, f1, f2
stfs f1, 16(r5)
stfs f1, 64(r5)
lfs f1, 104(r8)
fmuls f1, f1, f4
lfs f2, 116(r8)
fadds f1, f1, f2
lfs f2, 92(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
lfs f2, 136(r8)
fmuls f1, f1, f2
stfs f1, 32(r5)
stfs f1, 80(r5)
lwz r0, 4(r5)
stw r0, 96(r8)
lwz r0, 20(r5)
stw r0, 100(r8)
lwz r0, 36(r5)
stw r0, 104(r8)
lfs f1, 84(r8)
lfs f2, 96(r8)
fmuls f3, f1, f2
lfs f1, 88(r8)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 92(r8)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 152(r8)
lfs f1, 84(r8)
lfs f2, 88(r8)
lfs f3, 92(r8)
lfs f4, 96(r8)
lfs f5, 100(r8)
lfs f6, 104(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 108(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 112(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 116(r8)
lfs f4, 140(r8)
lfs f5, 152(r8)
lfs f6, 144(r8)
fmuls f5, f5, f6
lfs f1, 96(r8)
fmuls f1, f1, f4
lfs f2, 108(r8)
fadds f1, f1, f2
lfs f2, 84(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 4(r5)
fmuls f1, f1, f10
stfs f1, 52(r5)
lfs f1, 100(r8)
fmuls f1, f1, f4
lfs f2, 112(r8)
fadds f1, f1, f2
lfs f2, 88(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 20(r5)
fmuls f1, f1, f10
stfs f1, 68(r5)
lfs f1, 104(r8)
fmuls f1, f1, f4
lfs f2, 116(r8)
fadds f1, f1, f2
lfs f2, 92(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 36(r5)
fmuls f1, f1, f10
stfs f1, 84(r5)
lwz r0, 8(r5)
stw r0, 96(r8)
lwz r0, 24(r5)
stw r0, 100(r8)
lwz r0, 40(r5)
stw r0, 104(r8)
lfs f1, 84(r8)
lfs f2, 96(r8)
fmuls f3, f1, f2
lfs f1, 88(r8)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 92(r8)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 152(r8)
lfs f1, 84(r8)
lfs f2, 88(r8)
lfs f3, 92(r8)
lfs f4, 96(r8)
lfs f5, 100(r8)
lfs f6, 104(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 108(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 112(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 116(r8)
lfs f4, 140(r8)
lfs f5, 152(r8)
lfs f6, 144(r8)
fmuls f5, f5, f6
lfs f1, 96(r8)
fmuls f1, f1, f4
lfs f2, 108(r8)
fadds f1, f1, f2
lfs f2, 84(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 8(r5)
fmuls f1, f1, f10
stfs f1, 56(r5)
lfs f1, 100(r8)
fmuls f1, f1, f4
lfs f2, 112(r8)
fadds f1, f1, f2
lfs f2, 88(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 24(r5)
fmuls f1, f1, f10
stfs f1, 72(r5)
lfs f1, 104(r8)
fmuls f1, f1, f4
lfs f2, 116(r8)
fadds f1, f1, f2
lfs f2, 92(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 40(r5)
fmuls f1, f1, f10
stfs f1, 88(r5)
lfs f4, 120(r8)
lfs f2, 136(r8)
fmuls f4, f4, f2
lfs f1, 60(r8)
fmuls f1, f1, f4
lfs f2, 0(r8)
fadds f1, f1, f2
stfs f1, 60(r5)
lfs f1, 64(r8)
fmuls f1, f1, f4
lfs f2, 4(r8)
fadds f1, f1, f2
stfs f1, 76(r5)
lfs f1, 68(r8)
fmuls f1, f1, f4
lfs f2, 8(r8)
fadds f1, f1, f2
stfs f1, 92(r5)
li r0, 0
lfs f3, 160(r8)
fsubs f2, f9, f3
lfs f3, 176(r8)
fmuls f2, f2, f3
lfs f1, 220(r8)
fmuls f1, f1, f2
lfs f4, 208(r8)
fadds f1, f1, f4
stfs f1, 108(r5)
lfs f1, 224(r8)
fmuls f1, f1, f2
lfs f4, 212(r8)
fadds f1, f1, f4
stfs f1, 124(r5)
lfs f1, 228(r8)
fmuls f1, f1, f2
lfs f4, 216(r8)
fadds f1, f1, f4
stfs f1, 140(r5)
stw r0, 96(r5)
stw r0, 112(r5)
stw r0, 128(r5)
; the hand bone's cross-section axes: the forearm bone's columns 1 and 2 (52/68/84 and 56/72/88) turned by the smallest rotation taking the arm's
; axis a to the glove's axis g (R x = x + e x x + e x (e x x) / (1 + c), e = a x g, c = a . g; g = 0 leaves them as they are)
lfs f1, 60(r8)
lfs f2, 64(r8)
lfs f3, 68(r8)
lfs f4, 220(r8)
lfs f5, 224(r8)
lfs f6, 228(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
fmuls f8, f3, f4
fmuls f11, f1, f6
fsubs f8, f8, f11
fmuls f11, f1, f5
fmuls f12, f2, f4
fsubs f11, f11, f12
fmuls f12, f1, f4
fmuls f13, f2, f5
fadds f12, f12, f13
fmuls f13, f3, f6
fadds f12, f12, f13
lfs f13, 160(r8)
fadds f12, f12, f13
lfs f1, 164(r8)
.int 0xFC0C0800 ; fcmpu cr0, f12, f1
bge mtArmBendRotL
fsubs f7, f13, f13
fsubs f8, f13, f13
fsubs f11, f13, f13
fmr f12, f13
mtArmBendRotL:
.int 0xED8D6024 ; fdivs f12, f13, f12
lfs f1, 52(r5)
lfs f2, 68(r5)
lfs f3, 84(r5)
fmuls f4, f8, f3
fmuls f13, f11, f2
fsubs f4, f4, f13
fmuls f5, f11, f1
fmuls f13, f7, f3
fsubs f5, f5, f13
fmuls f6, f7, f2
fmuls f13, f8, f1
fsubs f6, f6, f13
fmuls f9, f8, f6
fmuls f13, f11, f5
fsubs f9, f9, f13
fmuls f10, f11, f4
fmuls f13, f7, f6
fsubs f10, f10, f13
fmuls f13, f7, f5
fmuls f0, f8, f4
fsubs f13, f13, f0
fmuls f9, f9, f12
fmuls f10, f10, f12
fmuls f13, f13, f12
fadds f1, f1, f4
fadds f1, f1, f9
stfs f1, 100(r5)
fadds f2, f2, f5
fadds f2, f2, f10
stfs f2, 116(r5)
fadds f3, f3, f6
fadds f3, f3, f13
stfs f3, 132(r5)
lfs f1, 56(r5)
lfs f2, 72(r5)
lfs f3, 88(r5)
fmuls f4, f8, f3
fmuls f13, f11, f2
fsubs f4, f4, f13
fmuls f5, f11, f1
fmuls f13, f7, f3
fsubs f5, f5, f13
fmuls f6, f7, f2
fmuls f13, f8, f1
fsubs f6, f6, f13
fmuls f9, f8, f6
fmuls f13, f11, f5
fsubs f9, f9, f13
fmuls f10, f11, f4
fmuls f13, f7, f6
fsubs f10, f10, f13
fmuls f13, f7, f5
fmuls f0, f8, f4
fsubs f13, f13, f0
fmuls f9, f9, f12
fmuls f10, f10, f12
fmuls f13, f13, f12
fadds f1, f1, f4
fadds f1, f1, f9
stfs f1, 104(r5)
fadds f2, f2, f5
fadds f2, f2, f10
stfs f2, 120(r5)
fadds f3, f3, f6
fadds f3, f3, f13
stfs f3, 136(r5)
mtArmEndPointL:
; the arm is built: kept as the pose to hold, and logged (mtArmLog)
lis r6, mtArmHold@ha
addi r6, r6, mtArmHold@l
addi r6, r6, 0
mr r7, r5
li r9, 36
mtArmHoldSaveL:
lwz r0, 0(r7)
stw r0, 0(r6)
addi r7, r7, 4
addi r6, r6, 4
addi r9, r9, -1
cmpwi r9, 0
bgt mtArmHoldSaveL
li r0, 1
stw r0, 0(r6)
li r0, 0
stw r0, 4(r6)
lis r6, mtArmLog@ha
addi r6, r6, mtArmLog@l
lwz r7, 0(r6)
andi. r9, r7, 127
mulli r9, r9, 64
add r9, r9, r6
addi r9, r9, 16
addi r7, r7, 1
stw r7, 0(r6)
li r0, 0
stw r0, 0(r9)
lis r7, mtFireStat@ha
addi r7, r7, mtFireStat@l
lwz r0, 4(r7)
stw r0, 4(r9)
lwz r0, 12(r7)
stw r0, 8(r9)
lis r7, 0x0180
lwz r0, 152(r7)
stw r0, 12(r9)
lwz r0, 0(r8)
stw r0, 16(r9)
lwz r0, 4(r8)
stw r0, 20(r9)
lwz r0, 8(r8)
stw r0, 24(r9)
lis r7, mtHandW@ha
addi r7, r7, mtHandW@l
lwz r0, 12(r7)
stw r0, 28(r9)
lwz r0, 28(r7)
stw r0, 32(r9)
lwz r0, 44(r7)
stw r0, 36(r9)
lwz r0, 96(r7)
stw r0, 60(r9)
lwz r0, 36(r8)
stw r0, 40(r9)
lwz r0, 40(r8)
stw r0, 44(r9)
lwz r0, 44(r8)
stw r0, 48(r9)
lwz r0, 136(r8)
stw r0, 52(r9)
lis r7, mtPad@ha
addi r7, r7, mtPad@l
lwz r0, 16(r7)
stw r0, 56(r9)
b mtArmDoneL
mtArmFailL:
; failed: the last good pose is held for a few frames before the arm shrinks into the shoulder (mtArmHold)
lis r6, mtArmLog@ha
addi r6, r6, mtArmLog@l
lwz r7, 0(r6)
andi. r9, r7, 127
mulli r9, r9, 64
add r9, r9, r6
addi r9, r9, 16
addi r7, r7, 1
stw r7, 0(r6)
li r0, 256
stw r0, 0(r9)
lis r7, mtFireStat@ha
addi r7, r7, mtFireStat@l
lwz r0, 4(r7)
stw r0, 4(r9)
lwz r0, 12(r7)
stw r0, 8(r9)
lis r7, 0x0180
lwz r0, 152(r7)
stw r0, 12(r9)
lwz r0, 0(r8)
stw r0, 16(r9)
lwz r0, 4(r8)
stw r0, 20(r9)
lwz r0, 8(r8)
stw r0, 24(r9)
lis r7, mtHandW@ha
addi r7, r7, mtHandW@l
lwz r0, 12(r7)
stw r0, 28(r9)
lwz r0, 28(r7)
stw r0, 32(r9)
lwz r0, 44(r7)
stw r0, 36(r9)
lwz r0, 96(r7)
stw r0, 60(r9)
lwz r0, 148(r8)
stw r0, 52(r9)
lis r7, mtPad@ha
addi r7, r7, mtPad@l
lwz r0, 16(r7)
stw r0, 56(r9)
lis r6, mtArmHold@ha
addi r6, r6, mtArmHold@l
addi r6, r6, 0
lwz r0, 144(r6)
cmpwi r0, 0
beq mtArmFailLZero
lwz r9, 148(r6)
cmpwi r9, 8
bge mtArmFailLZero
addi r9, r9, 1
stw r9, 148(r6)
lwz r9, 152(r6)
addi r9, r9, 1
stw r9, 152(r6)
mr r7, r5
li r9, 36
mtArmHoldBackL:
lwz r0, 0(r6)
stw r0, 0(r7)
addi r7, r7, 4
addi r6, r6, 4
addi r9, r9, -1
cmpwi r9, 0
bgt mtArmHoldBackL
b mtArmDoneL
mtArmFailLZero:
; not tracked (or a degenerate pose): the arm shrinks into the shoulder
li r0, 0
stw r0, 0(r5)
stw r0, 4(r5)
stw r0, 8(r5)
stw r0, 16(r5)
stw r0, 20(r5)
stw r0, 24(r5)
stw r0, 32(r5)
stw r0, 36(r5)
stw r0, 40(r5)
stw r0, 48(r5)
stw r0, 52(r5)
stw r0, 56(r5)
stw r0, 64(r5)
stw r0, 68(r5)
stw r0, 72(r5)
stw r0, 80(r5)
stw r0, 84(r5)
stw r0, 88(r5)
stw r0, 96(r5)
stw r0, 100(r5)
stw r0, 104(r5)
stw r0, 112(r5)
stw r0, 116(r5)
stw r0, 120(r5)
stw r0, 128(r5)
stw r0, 132(r5)
stw r0, 136(r5)
mtArmDoneL:
addi r5, r10, 912
lfs f9, 172(r8)
lfs f10, 180(r8)
; right arm: reach from the shoulder to the VR glove when it is tracked
lis r9, mtPad@ha
addi r9, r9, mtPad@l
lwz r0, 88(r9)
cmpwi r0, 1
bne mtArmFailR
lis r9, mtHandCtl@ha
addi r9, r9, mtHandCtl@l
lwz r0, 0(r9)
cmpwi r0, 0
beq mtArmFailR
lwz r6, 8(r9)
lis r9, 0x1000
cmplw r6, r9
blt mtArmFailR
lis r9, 0x5000
cmplw r6, r9
bge mtArmFailR
andi. r0, r6, 3
bne mtArmFailR
lwz r0, 12(r5)
stw r0, 0(r8)
lwz r0, 28(r5)
stw r0, 4(r8)
lwz r0, 44(r5)
stw r0, 8(r8)
lwz r0, 60(r5)
stw r0, 12(r8)
lwz r0, 76(r5)
stw r0, 16(r8)
lwz r0, 92(r5)
stw r0, 20(r8)
lwz r0, 108(r5)
stw r0, 24(r8)
lwz r0, 124(r5)
stw r0, 28(r8)
lwz r0, 140(r5)
stw r0, 32(r8)
; the glove's position: mtHandW, the newest matrix the pack gave the glove (the part's copy +0xB4 reached the arm a step late)
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
lwz r0, 100(r9)
cmpwi r0, 1
bne mtArmFailR
lwz r0, 60(r9)
stw r0, 36(r8)
lwz r0, 76(r9)
stw r0, 40(r8)
lwz r0, 92(r9)
stw r0, 44(r8)
lis r7, 0x0180
lwz r0, 152(r7)
cmpwi r0, 1
bne mtArmLeadNoR
lis r7, mtGlDbg@ha
addi r7, r7, mtGlDbg@l
lfs f1, 36(r8)
lfs f2, 12(r7)
fsubs f2, f1, f2
lfs f3, 40(r8)
lfs f4, 16(r7)
fsubs f4, f3, f4
lfs f5, 44(r8)
lfs f6, 20(r7)
fsubs f6, f5, f6
fmuls f7, f2, f2
fmuls f8, f4, f4
fadds f7, f7, f8
fmuls f8, f6, f6
fadds f7, f7, f8
lfs f8, 200(r8)
.int 0xFC074000 ; fcmpu cr0, f7, f8
bgt mtArmLeadNoR
lfs f7, 196(r8)
fmuls f2, f2, f7
fadds f1, f1, f2
stfs f1, 36(r8)
fmuls f4, f4, f7
fadds f3, f3, f4
stfs f3, 40(r8)
fmuls f6, f6, f7
fadds f5, f5, f6
stfs f5, 44(r8)
mtArmLeadNoR:
; the wrist (mtArmBend): the glove's place is kept, the arm is built toward a point behind it along the glove's finger axis
lfs f1, 36(r8)
stfs f1, 208(r8)
lfs f2, 40(r8)
stfs f2, 212(r8)
lfs f3, 44(r8)
stfs f3, 216(r8)
lwz r0, 232(r8)
cmpwi r0, 0
beq mtArmBendOffR
lfs f4, 56(r9)
lfs f5, 72(r9)
lfs f6, 88(r9)
fmuls f7, f4, f4
fmuls f8, f5, f5
fadds f7, f7, f8
fmuls f8, f6, f6
fadds f7, f7, f8
lfs f8, 164(r8)
fmuls f8, f8, f8
.int 0xFC074000 ; fcmpu cr0, f7, f8
blt mtArmBendOffR
.int 0xFD003834 ; frsqrte f8, f7
lfs f11, 52(r11)
lfs f12, 56(r11)
fmuls f13, f8, f8
fmuls f13, f13, f7
fmuls f13, f13, f11
fsubs f13, f12, f13
fmuls f8, f8, f13
fmuls f13, f8, f8
fmuls f13, f13, f7
fmuls f13, f13, f11
fsubs f13, f12, f13
fmuls f8, f8, f13
fmuls f4, f4, f8
fmuls f5, f5, f8
fmuls f6, f6, f8
stfs f4, 220(r8)
stfs f5, 224(r8)
stfs f6, 228(r8)
lfs f7, 204(r8)
fmuls f13, f4, f7
fsubs f1, f1, f13
stfs f1, 36(r8)
fmuls f13, f5, f7
fsubs f2, f2, f13
stfs f2, 40(r8)
fmuls f13, f6, f7
fsubs f3, f3, f13
stfs f3, 44(r8)
b mtArmBendDoneR
mtArmBendOffR:
li r0, 0
stw r0, 220(r8)
stw r0, 224(r8)
stw r0, 228(r8)
mtArmBendDoneR:
lfs f1, 192(r6)
lfs f2, 60(r9)
fsubs f1, f1, f2
fmuls f1, f1, f1
lfs f3, 208(r6)
lfs f4, 76(r9)
fsubs f3, f3, f4
fmuls f3, f3, f3
fadds f1, f1, f3
lfs f3, 224(r6)
lfs f4, 92(r9)
fsubs f3, f3, f4
fmuls f3, f3, f3
fadds f1, f1, f3
lis r7, mtGlDbg@ha
addi r7, r7, mtGlDbg@l
lfs f2, 48(r7)
.int 0xFC011000 ; fcmpu cr0, f1, f2
ble mtArmSameR
lwz r9, 188(r8)
addi r9, r9, 1
stw r9, 188(r8)
mtArmSameR:
lwz r9, 192(r8)
addi r9, r9, 1
stw r9, 192(r8)
lis r7, mtGlDbg@ha
addi r7, r7, mtGlDbg@l
lwz r9, 64(r7)
add r6, r7, r9
li r0, 33
stb r0, 68(r6)
addi r9, r9, 1
andi. r9, r9, 63
stw r9, 64(r7)
lfs f1, 12(r8)
lfs f2, 0(r8)
fsubs f1, f1, f2
stfs f1, 48(r8)
lfs f1, 16(r8)
lfs f2, 4(r8)
fsubs f1, f1, f2
stfs f1, 52(r8)
lfs f1, 20(r8)
lfs f2, 8(r8)
fsubs f1, f1, f2
stfs f1, 56(r8)
lfs f1, 48(r8)
lfs f2, 48(r8)
fmuls f3, f1, f2
lfs f1, 52(r8)
lfs f2, 52(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 56(r8)
lfs f2, 56(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailR
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 148(r8)
lfs f2, 132(r8)
fmuls f1, f1, f2
stfs f1, 120(r8)
lfs f1, 24(r8)
lfs f2, 12(r8)
fsubs f1, f1, f2
stfs f1, 48(r8)
lfs f1, 28(r8)
lfs f2, 16(r8)
fsubs f1, f1, f2
stfs f1, 52(r8)
lfs f1, 32(r8)
lfs f2, 20(r8)
fsubs f1, f1, f2
stfs f1, 56(r8)
lfs f1, 48(r8)
lfs f2, 48(r8)
fmuls f3, f1, f2
lfs f1, 52(r8)
lfs f2, 52(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 56(r8)
lfs f2, 56(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailR
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 148(r8)
lfs f2, 132(r8)
fmuls f1, f1, f2
stfs f1, 124(r8)
lfs f1, 36(r8)
lfs f2, 0(r8)
fsubs f1, f1, f2
stfs f1, 48(r8)
lfs f1, 40(r8)
lfs f2, 4(r8)
fsubs f1, f1, f2
stfs f1, 52(r8)
lfs f1, 44(r8)
lfs f2, 8(r8)
fsubs f1, f1, f2
stfs f1, 56(r8)
lfs f1, 48(r8)
lfs f2, 48(r8)
fmuls f3, f1, f2
lfs f1, 52(r8)
lfs f2, 52(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 56(r8)
lfs f2, 56(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailR
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 148(r8)
lfs f2, 132(r8)
fmuls f1, f1, f2
stfs f1, 128(r8)
lfs f4, 132(r8)
lfs f1, 48(r8)
fmuls f1, f1, f4
stfs f1, 60(r8)
lfs f1, 52(r8)
fmuls f1, f1, f4
stfs f1, 64(r8)
lfs f1, 56(r8)
fmuls f1, f1, f4
stfs f1, 68(r8)
lfs f1, 120(r8)
lfs f2, 124(r8)
fadds f1, f1, f2
stfs f1, 148(r8)
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f1, 132(r8)
fmuls f1, f1, f1
lfs f2, 128(r8)
fmuls f1, f1, f2
lfs f2, 168(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
ble mtArmKR
fmr f1, f2
lwz r9, 184(r8)
addi r9, r9, 1
stw r9, 184(r8)
mtArmKR:
stfs f1, 136(r8)
; mtArmCanon: this arm's bind frame under the body's root (the animation is ignored), turned half a turn when the glove is on the far side
lfs f1, 60(r8)
lfs f2, 64(r8)
lfs f3, 68(r8)
lfs f4, 0(r10)
lfs f5, 16(r10)
lfs f6, 32(r10)
fmuls f4, f1, f4
fmuls f5, f2, f5
fadds f4, f4, f5
fmuls f6, f3, f6
fadds f4, f4, f6
fsubs f7, f7, f7
.int 0xFC043800 ; fcmpu cr0, f4, f7
bgt mtArmCanonFlipR
lfs f1, 0(r10)
fneg f1, f1
stfs f1, 0(r5)
lfs f1, 16(r10)
fneg f1, f1
stfs f1, 16(r5)
lfs f1, 32(r10)
fneg f1, f1
stfs f1, 32(r5)
lfs f1, 4(r10)
fneg f1, f1
stfs f1, 4(r5)
lfs f1, 20(r10)
fneg f1, f1
stfs f1, 20(r5)
lfs f1, 36(r10)
fneg f1, f1
stfs f1, 36(r5)
lwz r0, 8(r10)
stw r0, 8(r5)
lwz r0, 24(r10)
stw r0, 24(r5)
lwz r0, 40(r10)
stw r0, 40(r5)
b mtArmCanonDoneR
mtArmCanonFlipR:
lwz r0, 0(r10)
stw r0, 0(r5)
lwz r0, 16(r10)
stw r0, 16(r5)
lwz r0, 32(r10)
stw r0, 32(r5)
lfs f1, 4(r10)
fneg f1, f1
stfs f1, 4(r5)
lfs f1, 20(r10)
fneg f1, f1
stfs f1, 20(r5)
lfs f1, 36(r10)
fneg f1, f1
stfs f1, 36(r5)
lfs f1, 8(r10)
fneg f1, f1
stfs f1, 8(r5)
lfs f1, 24(r10)
fneg f1, f1
stfs f1, 24(r5)
lfs f1, 40(r10)
fneg f1, f1
stfs f1, 40(r5)
mtArmCanonDoneR:
lwz r0, 0(r5)
stw r0, 72(r8)
lwz r0, 16(r5)
stw r0, 76(r8)
lwz r0, 32(r5)
stw r0, 80(r8)
lfs f1, 72(r8)
lfs f2, 72(r8)
fmuls f3, f1, f2
lfs f1, 76(r8)
lfs f2, 76(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 80(r8)
lfs f2, 80(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 148(r8)
lfs f1, 148(r8)
lfs f2, 160(r8)
fmuls f2, f2, f2
lfs f2, 164(r8)
fmuls f2, f2, f2
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailR
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 132(r8)
lfs f4, 132(r8)
lfs f1, 72(r8)
fmuls f1, f1, f4
stfs f1, 72(r8)
lfs f1, 76(r8)
fmuls f1, f1, f4
stfs f1, 76(r8)
lfs f1, 80(r8)
fmuls f1, f1, f4
stfs f1, 80(r8)
lfs f1, 72(r8)
lfs f2, 60(r8)
fmuls f3, f1, f2
lfs f1, 76(r8)
lfs f2, 64(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 80(r8)
lfs f2, 68(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 140(r8)
lfs f1, 72(r8)
lfs f2, 76(r8)
lfs f3, 80(r8)
lfs f4, 60(r8)
lfs f5, 64(r8)
lfs f6, 68(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 84(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 88(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 92(r8)
lfs f1, 140(r8)
lfs f2, 160(r8)
fadds f1, f1, f2
stfs f1, 148(r8)
lfs f2, 164(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtArmFailR
lfs f1, 148(r8)
.int 0xFC400834 ; frsqrte f2, f1
lfs f7, 52(r11)
lfs f8, 56(r11)
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
fmuls f3, f2, f2
fmuls f3, f3, f1
fmuls f3, f3, f7
fsubs f3, f8, f3
fmuls f2, f2, f3
stfs f2, 144(r8)
lfs f1, 144(r8)
fmuls f1, f1, f1
stfs f1, 144(r8)
lwz r0, 0(r5)
stw r0, 96(r8)
lwz r0, 16(r5)
stw r0, 100(r8)
lwz r0, 32(r5)
stw r0, 104(r8)
lfs f1, 84(r8)
lfs f2, 96(r8)
fmuls f3, f1, f2
lfs f1, 88(r8)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 92(r8)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 152(r8)
lfs f1, 84(r8)
lfs f2, 88(r8)
lfs f3, 92(r8)
lfs f4, 96(r8)
lfs f5, 100(r8)
lfs f6, 104(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 108(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 112(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 116(r8)
lfs f4, 140(r8)
lfs f5, 152(r8)
lfs f6, 144(r8)
fmuls f5, f5, f6
lfs f1, 96(r8)
fmuls f1, f1, f4
lfs f2, 108(r8)
fadds f1, f1, f2
lfs f2, 84(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
lfs f2, 136(r8)
fmuls f1, f1, f2
stfs f1, 0(r5)
stfs f1, 48(r5)
lfs f1, 100(r8)
fmuls f1, f1, f4
lfs f2, 112(r8)
fadds f1, f1, f2
lfs f2, 88(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
lfs f2, 136(r8)
fmuls f1, f1, f2
stfs f1, 16(r5)
stfs f1, 64(r5)
lfs f1, 104(r8)
fmuls f1, f1, f4
lfs f2, 116(r8)
fadds f1, f1, f2
lfs f2, 92(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
lfs f2, 136(r8)
fmuls f1, f1, f2
stfs f1, 32(r5)
stfs f1, 80(r5)
lwz r0, 4(r5)
stw r0, 96(r8)
lwz r0, 20(r5)
stw r0, 100(r8)
lwz r0, 36(r5)
stw r0, 104(r8)
lfs f1, 84(r8)
lfs f2, 96(r8)
fmuls f3, f1, f2
lfs f1, 88(r8)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 92(r8)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 152(r8)
lfs f1, 84(r8)
lfs f2, 88(r8)
lfs f3, 92(r8)
lfs f4, 96(r8)
lfs f5, 100(r8)
lfs f6, 104(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 108(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 112(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 116(r8)
lfs f4, 140(r8)
lfs f5, 152(r8)
lfs f6, 144(r8)
fmuls f5, f5, f6
lfs f1, 96(r8)
fmuls f1, f1, f4
lfs f2, 108(r8)
fadds f1, f1, f2
lfs f2, 84(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 4(r5)
fmuls f1, f1, f10
stfs f1, 52(r5)
lfs f1, 100(r8)
fmuls f1, f1, f4
lfs f2, 112(r8)
fadds f1, f1, f2
lfs f2, 88(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 20(r5)
fmuls f1, f1, f10
stfs f1, 68(r5)
lfs f1, 104(r8)
fmuls f1, f1, f4
lfs f2, 116(r8)
fadds f1, f1, f2
lfs f2, 92(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 36(r5)
fmuls f1, f1, f10
stfs f1, 84(r5)
lwz r0, 8(r5)
stw r0, 96(r8)
lwz r0, 24(r5)
stw r0, 100(r8)
lwz r0, 40(r5)
stw r0, 104(r8)
lfs f1, 84(r8)
lfs f2, 96(r8)
fmuls f3, f1, f2
lfs f1, 88(r8)
lfs f2, 100(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
lfs f1, 92(r8)
lfs f2, 104(r8)
fmuls f1, f1, f2
fadds f3, f3, f1
stfs f3, 152(r8)
lfs f1, 84(r8)
lfs f2, 88(r8)
lfs f3, 92(r8)
lfs f4, 96(r8)
lfs f5, 100(r8)
lfs f6, 104(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
stfs f7, 108(r8)
fmuls f7, f3, f4
fmuls f8, f1, f6
fsubs f7, f7, f8
stfs f7, 112(r8)
fmuls f7, f1, f5
fmuls f8, f2, f4
fsubs f7, f7, f8
stfs f7, 116(r8)
lfs f4, 140(r8)
lfs f5, 152(r8)
lfs f6, 144(r8)
fmuls f5, f5, f6
lfs f1, 96(r8)
fmuls f1, f1, f4
lfs f2, 108(r8)
fadds f1, f1, f2
lfs f2, 84(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 8(r5)
fmuls f1, f1, f10
stfs f1, 56(r5)
lfs f1, 100(r8)
fmuls f1, f1, f4
lfs f2, 112(r8)
fadds f1, f1, f2
lfs f2, 88(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 24(r5)
fmuls f1, f1, f10
stfs f1, 72(r5)
lfs f1, 104(r8)
fmuls f1, f1, f4
lfs f2, 116(r8)
fadds f1, f1, f2
lfs f2, 92(r8)
fmuls f2, f2, f5
fadds f1, f1, f2
fmuls f1, f1, f9
stfs f1, 40(r5)
fmuls f1, f1, f10
stfs f1, 88(r5)
lfs f4, 120(r8)
lfs f2, 136(r8)
fmuls f4, f4, f2
lfs f1, 60(r8)
fmuls f1, f1, f4
lfs f2, 0(r8)
fadds f1, f1, f2
stfs f1, 60(r5)
lfs f1, 64(r8)
fmuls f1, f1, f4
lfs f2, 4(r8)
fadds f1, f1, f2
stfs f1, 76(r5)
lfs f1, 68(r8)
fmuls f1, f1, f4
lfs f2, 8(r8)
fadds f1, f1, f2
stfs f1, 92(r5)
li r0, 0
lfs f3, 160(r8)
fsubs f2, f9, f3
lfs f3, 176(r8)
fmuls f2, f2, f3
lfs f1, 220(r8)
fmuls f1, f1, f2
lfs f4, 208(r8)
fadds f1, f1, f4
stfs f1, 108(r5)
lfs f1, 224(r8)
fmuls f1, f1, f2
lfs f4, 212(r8)
fadds f1, f1, f4
stfs f1, 124(r5)
lfs f1, 228(r8)
fmuls f1, f1, f2
lfs f4, 216(r8)
fadds f1, f1, f4
stfs f1, 140(r5)
stw r0, 96(r5)
stw r0, 112(r5)
stw r0, 128(r5)
; the hand bone's cross-section axes: the forearm bone's columns 1 and 2 (52/68/84 and 56/72/88) turned by the smallest rotation taking the arm's
; axis a to the glove's axis g (R x = x + e x x + e x (e x x) / (1 + c), e = a x g, c = a . g; g = 0 leaves them as they are)
lfs f1, 60(r8)
lfs f2, 64(r8)
lfs f3, 68(r8)
lfs f4, 220(r8)
lfs f5, 224(r8)
lfs f6, 228(r8)
fmuls f7, f2, f6
fmuls f8, f3, f5
fsubs f7, f7, f8
fmuls f8, f3, f4
fmuls f11, f1, f6
fsubs f8, f8, f11
fmuls f11, f1, f5
fmuls f12, f2, f4
fsubs f11, f11, f12
fmuls f12, f1, f4
fmuls f13, f2, f5
fadds f12, f12, f13
fmuls f13, f3, f6
fadds f12, f12, f13
lfs f13, 160(r8)
fadds f12, f12, f13
lfs f1, 164(r8)
.int 0xFC0C0800 ; fcmpu cr0, f12, f1
bge mtArmBendRotR
fsubs f7, f13, f13
fsubs f8, f13, f13
fsubs f11, f13, f13
fmr f12, f13
mtArmBendRotR:
.int 0xED8D6024 ; fdivs f12, f13, f12
lfs f1, 52(r5)
lfs f2, 68(r5)
lfs f3, 84(r5)
fmuls f4, f8, f3
fmuls f13, f11, f2
fsubs f4, f4, f13
fmuls f5, f11, f1
fmuls f13, f7, f3
fsubs f5, f5, f13
fmuls f6, f7, f2
fmuls f13, f8, f1
fsubs f6, f6, f13
fmuls f9, f8, f6
fmuls f13, f11, f5
fsubs f9, f9, f13
fmuls f10, f11, f4
fmuls f13, f7, f6
fsubs f10, f10, f13
fmuls f13, f7, f5
fmuls f0, f8, f4
fsubs f13, f13, f0
fmuls f9, f9, f12
fmuls f10, f10, f12
fmuls f13, f13, f12
fadds f1, f1, f4
fadds f1, f1, f9
stfs f1, 100(r5)
fadds f2, f2, f5
fadds f2, f2, f10
stfs f2, 116(r5)
fadds f3, f3, f6
fadds f3, f3, f13
stfs f3, 132(r5)
lfs f1, 56(r5)
lfs f2, 72(r5)
lfs f3, 88(r5)
fmuls f4, f8, f3
fmuls f13, f11, f2
fsubs f4, f4, f13
fmuls f5, f11, f1
fmuls f13, f7, f3
fsubs f5, f5, f13
fmuls f6, f7, f2
fmuls f13, f8, f1
fsubs f6, f6, f13
fmuls f9, f8, f6
fmuls f13, f11, f5
fsubs f9, f9, f13
fmuls f10, f11, f4
fmuls f13, f7, f6
fsubs f10, f10, f13
fmuls f13, f7, f5
fmuls f0, f8, f4
fsubs f13, f13, f0
fmuls f9, f9, f12
fmuls f10, f10, f12
fmuls f13, f13, f12
fadds f1, f1, f4
fadds f1, f1, f9
stfs f1, 104(r5)
fadds f2, f2, f5
fadds f2, f2, f10
stfs f2, 120(r5)
fadds f3, f3, f6
fadds f3, f3, f13
stfs f3, 136(r5)
mtArmEndPointR:
; the arm is built: kept as the pose to hold, and logged (mtArmLog)
lis r6, mtArmHold@ha
addi r6, r6, mtArmHold@l
addi r6, r6, 160
mr r7, r5
li r9, 36
mtArmHoldSaveR:
lwz r0, 0(r7)
stw r0, 0(r6)
addi r7, r7, 4
addi r6, r6, 4
addi r9, r9, -1
cmpwi r9, 0
bgt mtArmHoldSaveR
li r0, 1
stw r0, 0(r6)
li r0, 0
stw r0, 4(r6)
lis r6, mtArmLog@ha
addi r6, r6, mtArmLog@l
lwz r7, 0(r6)
andi. r9, r7, 127
mulli r9, r9, 64
add r9, r9, r6
addi r9, r9, 16
addi r7, r7, 1
stw r7, 0(r6)
li r0, 1
stw r0, 0(r9)
lis r7, mtFireStat@ha
addi r7, r7, mtFireStat@l
lwz r0, 4(r7)
stw r0, 4(r9)
lwz r0, 12(r7)
stw r0, 8(r9)
lis r7, 0x0180
lwz r0, 152(r7)
stw r0, 12(r9)
lwz r0, 0(r8)
stw r0, 16(r9)
lwz r0, 4(r8)
stw r0, 20(r9)
lwz r0, 8(r8)
stw r0, 24(r9)
lis r7, mtHandW@ha
addi r7, r7, mtHandW@l
lwz r0, 60(r7)
stw r0, 28(r9)
lwz r0, 76(r7)
stw r0, 32(r9)
lwz r0, 92(r7)
stw r0, 36(r9)
lwz r0, 100(r7)
stw r0, 60(r9)
lwz r0, 36(r8)
stw r0, 40(r9)
lwz r0, 40(r8)
stw r0, 44(r9)
lwz r0, 44(r8)
stw r0, 48(r9)
lwz r0, 136(r8)
stw r0, 52(r9)
lis r7, mtPad@ha
addi r7, r7, mtPad@l
lwz r0, 88(r7)
stw r0, 56(r9)
b mtArmDoneR
mtArmFailR:
; failed: the last good pose is held for a few frames before the arm shrinks into the shoulder (mtArmHold)
lis r6, mtArmLog@ha
addi r6, r6, mtArmLog@l
lwz r7, 0(r6)
andi. r9, r7, 127
mulli r9, r9, 64
add r9, r9, r6
addi r9, r9, 16
addi r7, r7, 1
stw r7, 0(r6)
li r0, 257
stw r0, 0(r9)
lis r7, mtFireStat@ha
addi r7, r7, mtFireStat@l
lwz r0, 4(r7)
stw r0, 4(r9)
lwz r0, 12(r7)
stw r0, 8(r9)
lis r7, 0x0180
lwz r0, 152(r7)
stw r0, 12(r9)
lwz r0, 0(r8)
stw r0, 16(r9)
lwz r0, 4(r8)
stw r0, 20(r9)
lwz r0, 8(r8)
stw r0, 24(r9)
lis r7, mtHandW@ha
addi r7, r7, mtHandW@l
lwz r0, 60(r7)
stw r0, 28(r9)
lwz r0, 76(r7)
stw r0, 32(r9)
lwz r0, 92(r7)
stw r0, 36(r9)
lwz r0, 100(r7)
stw r0, 60(r9)
lwz r0, 148(r8)
stw r0, 52(r9)
lis r7, mtPad@ha
addi r7, r7, mtPad@l
lwz r0, 88(r7)
stw r0, 56(r9)
lis r6, mtArmHold@ha
addi r6, r6, mtArmHold@l
addi r6, r6, 160
lwz r0, 144(r6)
cmpwi r0, 0
beq mtArmFailRZero
lwz r9, 148(r6)
cmpwi r9, 8
bge mtArmFailRZero
addi r9, r9, 1
stw r9, 148(r6)
lwz r9, 152(r6)
addi r9, r9, 1
stw r9, 152(r6)
mr r7, r5
li r9, 36
mtArmHoldBackR:
lwz r0, 0(r6)
stw r0, 0(r7)
addi r7, r7, 4
addi r6, r6, 4
addi r9, r9, -1
cmpwi r9, 0
bgt mtArmHoldBackR
b mtArmDoneR
mtArmFailRZero:
; not tracked (or a degenerate pose): the arm shrinks into the shoulder
li r0, 0
stw r0, 0(r5)
stw r0, 4(r5)
stw r0, 8(r5)
stw r0, 16(r5)
stw r0, 20(r5)
stw r0, 24(r5)
stw r0, 32(r5)
stw r0, 36(r5)
stw r0, 40(r5)
stw r0, 48(r5)
stw r0, 52(r5)
stw r0, 56(r5)
stw r0, 64(r5)
stw r0, 68(r5)
stw r0, 72(r5)
stw r0, 80(r5)
stw r0, 84(r5)
stw r0, 88(r5)
stw r0, 96(r5)
stw r0, 100(r5)
stw r0, 104(r5)
stw r0, 112(r5)
stw r0, 116(r5)
stw r0, 120(r5)
stw r0, 128(r5)
stw r0, 132(r5)
stw r0, 136(r5)
mtArmDoneR:
mtHeadCall:
mflr r0
stwu r1, -0x10(r1)
stw r0, 0x14(r1)
bl mtHeadOrig
lis r11, mtHeadSave@ha
addi r11, r11, mtHeadSave@l
lwz r10, 36(r11)
lwz r0, 44(r11)
cmpwi r0, 0
beq mtHeadNoHeadBack
addi r9, r10, 624
lwz r0, 0(r11)
stw r0, 0(r9)
lwz r0, 4(r11)
stw r0, 4(r9)
lwz r0, 8(r11)
stw r0, 8(r9)
lwz r0, 12(r11)
stw r0, 16(r9)
lwz r0, 16(r11)
stw r0, 20(r9)
lwz r0, 20(r11)
stw r0, 24(r9)
lwz r0, 24(r11)
stw r0, 32(r9)
lwz r0, 28(r11)
stw r0, 36(r9)
lwz r0, 32(r11)
stw r0, 40(r9)
mtHeadNoHeadBack:
lwz r0, 60(r11)
cmpwi r0, 0
beq mtHeadNoArmsBack
lis r7, mtArmSave@ha
addi r7, r7, mtArmSave@l
addi r9, r10, 720
lwz r0, 0(r7)
stw r0, 0(r9)
lwz r0, 4(r7)
stw r0, 4(r9)
lwz r0, 8(r7)
stw r0, 8(r9)
lwz r0, 12(r7)
stw r0, 12(r9)
lwz r0, 16(r7)
stw r0, 16(r9)
lwz r0, 20(r7)
stw r0, 20(r9)
lwz r0, 24(r7)
stw r0, 24(r9)
lwz r0, 28(r7)
stw r0, 28(r9)
lwz r0, 32(r7)
stw r0, 32(r9)
lwz r0, 36(r7)
stw r0, 36(r9)
lwz r0, 40(r7)
stw r0, 40(r9)
lwz r0, 44(r7)
stw r0, 44(r9)
addi r9, r10, 768
lwz r0, 48(r7)
stw r0, 0(r9)
lwz r0, 52(r7)
stw r0, 4(r9)
lwz r0, 56(r7)
stw r0, 8(r9)
lwz r0, 60(r7)
stw r0, 12(r9)
lwz r0, 64(r7)
stw r0, 16(r9)
lwz r0, 68(r7)
stw r0, 20(r9)
lwz r0, 72(r7)
stw r0, 24(r9)
lwz r0, 76(r7)
stw r0, 28(r9)
lwz r0, 80(r7)
stw r0, 32(r9)
lwz r0, 84(r7)
stw r0, 36(r9)
lwz r0, 88(r7)
stw r0, 40(r9)
lwz r0, 92(r7)
stw r0, 44(r9)
addi r9, r10, 816
lwz r0, 96(r7)
stw r0, 0(r9)
lwz r0, 100(r7)
stw r0, 4(r9)
lwz r0, 104(r7)
stw r0, 8(r9)
lwz r0, 108(r7)
stw r0, 12(r9)
lwz r0, 112(r7)
stw r0, 16(r9)
lwz r0, 116(r7)
stw r0, 20(r9)
lwz r0, 120(r7)
stw r0, 24(r9)
lwz r0, 124(r7)
stw r0, 28(r9)
lwz r0, 128(r7)
stw r0, 32(r9)
lwz r0, 132(r7)
stw r0, 36(r9)
lwz r0, 136(r7)
stw r0, 40(r9)
lwz r0, 140(r7)
stw r0, 44(r9)
addi r9, r10, 912
lwz r0, 144(r7)
stw r0, 0(r9)
lwz r0, 148(r7)
stw r0, 4(r9)
lwz r0, 152(r7)
stw r0, 8(r9)
lwz r0, 156(r7)
stw r0, 12(r9)
lwz r0, 160(r7)
stw r0, 16(r9)
lwz r0, 164(r7)
stw r0, 20(r9)
lwz r0, 168(r7)
stw r0, 24(r9)
lwz r0, 172(r7)
stw r0, 28(r9)
lwz r0, 176(r7)
stw r0, 32(r9)
lwz r0, 180(r7)
stw r0, 36(r9)
lwz r0, 184(r7)
stw r0, 40(r9)
lwz r0, 188(r7)
stw r0, 44(r9)
addi r9, r10, 960
lwz r0, 192(r7)
stw r0, 0(r9)
lwz r0, 196(r7)
stw r0, 4(r9)
lwz r0, 200(r7)
stw r0, 8(r9)
lwz r0, 204(r7)
stw r0, 12(r9)
lwz r0, 208(r7)
stw r0, 16(r9)
lwz r0, 212(r7)
stw r0, 20(r9)
lwz r0, 216(r7)
stw r0, 24(r9)
lwz r0, 220(r7)
stw r0, 28(r9)
lwz r0, 224(r7)
stw r0, 32(r9)
lwz r0, 228(r7)
stw r0, 36(r9)
lwz r0, 232(r7)
stw r0, 40(r9)
lwz r0, 236(r7)
stw r0, 44(r9)
addi r9, r10, 1008
lwz r0, 240(r7)
stw r0, 0(r9)
lwz r0, 244(r7)
stw r0, 4(r9)
lwz r0, 248(r7)
stw r0, 8(r9)
lwz r0, 252(r7)
stw r0, 12(r9)
lwz r0, 256(r7)
stw r0, 16(r9)
lwz r0, 260(r7)
stw r0, 20(r9)
lwz r0, 264(r7)
stw r0, 24(r9)
lwz r0, 268(r7)
stw r0, 28(r9)
lwz r0, 272(r7)
stw r0, 32(r9)
lwz r0, 276(r7)
stw r0, 36(r9)
lwz r0, 280(r7)
stw r0, 40(r9)
lwz r0, 284(r7)
stw r0, 44(r9)
mtHeadNoArmsBack:
lwz r0, 40(r11)
cmpwi r0, 0
beq mtHeadDone
mr r5, r10
addi r6, r11, 64
li r7, 22
mtHeadBackLoop:
lwz r0, 0(r6)
stw r0, 0(r5)
lwz r0, 16(r6)
stw r0, 32(r5)
lwz r0, 4(r6)
stw r0, 4(r5)
lwz r0, 20(r6)
stw r0, 36(r5)
lwz r0, 8(r6)
stw r0, 8(r5)
lwz r0, 24(r6)
stw r0, 40(r5)
lwz r0, 12(r6)
stw r0, 12(r5)
lwz r0, 28(r6)
stw r0, 44(r5)
addi r5, r5, 48
addi r6, r6, 32
addi r7, r7, -1
cmpwi r7, 0
bgt mtHeadBackLoop
mtHeadDone:
lwz r0, 0x14(r1)
mtlr r0
addi r1, r1, 0x10
blr
; A part hanging from the body (skirt, tail) has its own skeleton: while the body is turned
; with the view (mtTurnKeep, the body's last turn), turn it the same way about the same axis.
mtPartTry:
lwz r0, 12(r12)
cmpwi r0, 0
beq mtHeadOrig
lis r7, mtTurnKeep@ha
addi r7, r7, mtTurnKeep@l
lwz r0, 16(r7)
cmpwi r0, 0
beq mtHeadOrig
; the Bill Box suit (mtPipeEye+24 > 0, its skeleton in mtBoxHide+16) is turned with the view like a part
lis r6, mtPipeEye@ha
addi r6, r6, mtPipeEye@l
lwz r0, 24(r6)
cmpwi r0, 0
ble mtBoxTurnNo
lis r6, mtBoxHide@ha
addi r6, r6, mtBoxHide@l
lwz r6, 16(r6)
cmpw r6, r3
beq mtPartTurn
mtBoxTurnNo:
lwz r5, 16(r8)
cmplwi r5, 17
bgt mtHeadOrig
addi r8, r8, 24
mtPartLoop:
addi r5, r5, -1
cmpwi r5, 0
ble mtHeadOrig
lwz r9, 0(r8)
addi r8, r8, 4
lis r11, 0x1000
cmplw r9, r11
blt mtPartLoop
lis r11, 0x5000
cmplw r9, r11
bge mtPartLoop
andi. r0, r9, 3
bne mtPartLoop
lwz r6, 0(r9)
lis r11, 0x1000
cmplw r6, r11
blt mtPartLoop
lis r11, 0x5000
cmplw r6, r11
bge mtPartLoop
andi. r0, r6, 3
bne mtPartLoop
lwz r6, 24(r6)
cmpw r6, r3
bne mtPartLoop
lwz r6, 0(r9)
lis r11, 0x1000
cmplw r6, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r6, r11
bge mtHeadOrig
andi. r0, r6, 3
bne mtHeadOrig
lwz r6, 0(r6)
lis r11, 0x1000
cmplw r6, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r6, r11
bge mtHeadOrig
andi. r0, r6, 3
bne mtHeadOrig
lwz r0, 4(r6)
add r6, r6, r0
addi r6, r6, 4
lis r11, 0x1000
cmplw r6, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r6, r11
bge mtHeadOrig
li r11, 48
mtNameP:
lbz r0, 0(r6)
cmpwi r0, 0
beq mtHeadOrig
cmpwi r0, 0x53
bne mtNameTP
lbz r0, 1(r6)
cmpwi r0, 0x6B
bne mtNameNextP
lbz r0, 2(r6)
cmpwi r0, 0x69
beq mtPartTurn
b mtNameNextP
mtNameTP:
cmpwi r0, 0x54
bne mtNameNextP
lbz r0, 1(r6)
cmpwi r0, 0x61
bne mtNameNextP
lbz r0, 2(r6)
cmpwi r0, 0x69
beq mtPartTurn
mtNameNextP:
addi r6, r6, 1
addi r11, r11, -1
cmpwi r11, 0
bgt mtNameP
b mtHeadOrig
mtPartTurn:
lwz r6, 0(r3)
lis r11, 0x1000
cmplw r6, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r6, r11
bge mtHeadOrig
andi. r0, r6, 3
bne mtHeadOrig
lhz r5, 8(r6)
cmpwi r5, 0
ble mtHeadOrig
cmpwi r5, 16
bgt mtHeadOrig
lwz r6, 16(r3)
lis r11, 0x1000
cmplw r6, r11
blt mtHeadOrig
lis r11, 0x5000
cmplw r6, r11
bge mtHeadOrig
andi. r0, r6, 3
bne mtHeadOrig
lis r7, mtTurnKeep@ha
addi r7, r7, mtTurnKeep@l
lfs f5, 0(r7)
lfs f6, 4(r7)
lfs f9, 8(r7)
lfs f10, 12(r7)
lfs f13, 20(r7)
lfs f0, 24(r7)
lis r8, mtPartSave@ha
addi r8, r8, mtPartSave@l
stw r6, 0(r8)
stw r5, 4(r8)
addi r9, r8, 8
mtPartTurnLoop:
lwz r0, 0(r6)
stw r0, 0(r9)
lwz r0, 32(r6)
stw r0, 16(r9)
lfs f1, 0(r6)
lfs f2, 32(r6)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
stfs f3, 0(r6)
stfs f4, 32(r6)
lwz r0, 4(r6)
stw r0, 4(r9)
lwz r0, 36(r6)
stw r0, 20(r9)
lfs f1, 4(r6)
lfs f2, 36(r6)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
stfs f3, 4(r6)
stfs f4, 36(r6)
lwz r0, 8(r6)
stw r0, 8(r9)
lwz r0, 40(r6)
stw r0, 24(r9)
lfs f1, 8(r6)
lfs f2, 40(r6)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
stfs f3, 8(r6)
stfs f4, 40(r6)
lwz r0, 12(r6)
stw r0, 12(r9)
lwz r0, 44(r6)
stw r0, 28(r9)
lfs f1, 12(r6)
lfs f2, 44(r6)
fsubs f1, f1, f9
fsubs f2, f2, f10
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f7, f6, f1
fsubs f4, f4, f7
fadds f3, f3, f13
fadds f4, f4, f0
stfs f3, 12(r6)
stfs f4, 44(r6)
addi r6, r6, 48
addi r9, r9, 32
addi r5, r5, -1
cmpwi r5, 0
bgt mtPartTurnLoop
mflr r0
stwu r1, -0x10(r1)
stw r0, 0x14(r1)
bl mtHeadOrig
lis r8, mtPartSave@ha
addi r8, r8, mtPartSave@l
lwz r6, 0(r8)
lwz r5, 4(r8)
addi r9, r8, 8
mtPartBackLoop:
lwz r0, 0(r9)
stw r0, 0(r6)
lwz r0, 16(r9)
stw r0, 32(r6)
lwz r0, 4(r9)
stw r0, 4(r6)
lwz r0, 20(r9)
stw r0, 36(r6)
lwz r0, 8(r9)
stw r0, 8(r6)
lwz r0, 24(r9)
stw r0, 40(r6)
lwz r0, 12(r9)
stw r0, 12(r6)
lwz r0, 28(r9)
stw r0, 44(r6)
addi r6, r6, 48
addi r9, r9, 32
addi r5, r5, -1
cmpwi r5, 0
bgt mtPartBackLoop
lwz r0, 0x14(r1)
mtlr r0
addi r1, r1, 0x10
blr
; the original function (its first instruction, then the rest in place)
mtHeadOrig:
stwu r1, -0x78(r1)
b mtCalcBlockResume
0x023DAD0C = ba mtHeadWrap

; The player's shadow in first person: SM3DW draws it from shadow masks (ellipsoids and
; cylinders hung on the body's joints). Each mask hands its world matrix to a submit function
; that copies it into the frame's pool; for the player's own masks (category 4 = Player, host
; = the player or one of its captured models) the copy is turned and moved like the body
; (mtTurnKeep), so the shadow stays under the body when the view is pulled back.
0x0245A8F0 = mtShEllResume:
mtShEll:
; r4 = the mask's world matrix, r5 = &mask->Color (mask = r5 - 0x14), r6 = DrawCategory
cmpwi r6, 4
bne mtShEllOrig
lis r12, mtTurnKeep@ha
addi r12, r12, mtTurnKeep@l
; r8 = 1 while the body is drawn turned/moved (then the shadow goes with it), else 0
li r8, 1
lwz r0, 16(r12)
cmpwi r0, 0
bne mtShEllKeepOk
li r8, 0
mtShEllKeepOk:
lwz r9, 28(r12)
lis r10, mtHideModel@ha
addi r10, r10, mtHideModel@l
lwz r10, 12(r10)
subf r9, r9, r10
cmplwi r9, 2
ble mtShEllFresh
li r8, 0
mtShEllFresh:
; without the body turn the shadow is still made easier to see, in the original first person only
cmpwi r8, 0
bne mtShEllGo
lis r10, mtEyeBack@ha
lwz r0, mtEyeBack@l(r10)
cmpwi r0, 0
bne mtShEllOrig
lis r10, mtControl@ha
addi r10, r10, mtControl@l
lwz r0, 28(r10)
cmpwi r0, 1
bne mtShEllOrig
mtShEllGo:
lis r10, mtShStat@ha
addi r10, r10, mtShStat@l
lwz r9, 4(r10)
addi r9, r9, 1
stw r9, 4(r10)
lwz r11, -0x14(r5)
lis r10, 0x1000
cmplw r11, r10
blt mtShEllOrig
lis r10, 0x5000
cmplw r11, r10
bge mtShEllOrig
andi. r0, r11, 3
bne mtShEllOrig
; the player's costume actor itself, or a part actor whose model ([[+0x44]]+8) is captured
lis r10, mtHideHost@ha
lwz r0, mtHideHost@l(r10)
cmpw r0, r11
beq mtShEllMine
lwz r11, 0x44(r11)
lis r10, 0x1000
cmplw r11, r10
blt mtShEllOrig
lis r10, 0x5000
cmplw r11, r10
bge mtShEllOrig
andi. r0, r11, 3
bne mtShEllOrig
lwz r11, 0(r11)
lis r10, 0x1000
cmplw r11, r10
blt mtShEllOrig
lis r10, 0x5000
cmplw r11, r10
bge mtShEllOrig
andi. r0, r11, 3
bne mtShEllOrig
lwz r11, 8(r11)
lis r10, mtHideModel@ha
addi r10, r10, mtHideModel@l
lwz r9, 16(r10)
cmplwi r9, 17
bgt mtShEllOrig
addi r10, r10, 20
mtShEllFind:
cmpwi r9, 0
ble mtShEllOrig
lwz r0, 0(r10)
cmpw r0, r11
beq mtShEllMine
addi r10, r10, 4
addi r9, r9, -1
b mtShEllFind
mtShEllMine:
lis r10, mtShStat@ha
addi r10, r10, mtShStat@l
lwz r9, 8(r10)
addi r9, r9, 1
stw r9, 8(r10)
; the last matched mask's own position (diagnostics)
lwz r9, 12(r4)
stw r9, 12(r10)
lwz r9, 28(r4)
stw r9, 16(r10)
lwz r9, 44(r4)
stw r9, 20(r10)
; a copy of it, turned and moved exactly like the body (the submit copies it at once)
lis r11, mtShScratch@ha
addi r11, r11, mtShScratch@l
lwz r0, 0(r4)
stw r0, 0(r11)
lwz r0, 4(r4)
stw r0, 4(r11)
lwz r0, 8(r4)
stw r0, 8(r11)
lwz r0, 12(r4)
stw r0, 12(r11)
lwz r0, 16(r4)
stw r0, 16(r11)
lwz r0, 20(r4)
stw r0, 20(r11)
lwz r0, 24(r4)
stw r0, 24(r11)
lwz r0, 28(r4)
stw r0, 28(r11)
lwz r0, 32(r4)
stw r0, 32(r11)
lwz r0, 36(r4)
stw r0, 36(r11)
lwz r0, 40(r4)
stw r0, 40(r11)
lwz r0, 44(r4)
stw r0, 44(r11)
cmpwi r8, 0
beq mtShEllNoTurn
lfs f5, 0(r12)
lfs f6, 4(r12)
lfs f9, 8(r12)
lfs f10, 12(r12)
lfs f13, 20(r12)
lfs f0, 24(r12)
lfs f7, 0(r11)
lfs f8, 32(r11)
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
stfs f11, 0(r11)
stfs f12, 32(r11)
lfs f7, 4(r11)
lfs f8, 36(r11)
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
stfs f11, 4(r11)
stfs f12, 36(r11)
lfs f7, 8(r11)
lfs f8, 40(r11)
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
stfs f11, 8(r11)
stfs f12, 40(r11)
lfs f7, 12(r11)
lfs f8, 44(r11)
fsubs f7, f7, f9
fsubs f8, f8, f10
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
fadds f11, f11, f13
fadds f12, f12, f0
stfs f11, 12(r11)
stfs f12, 44(r11)
mtShEllNoTurn:
; first person: the landing shadow a bit bigger (mtShLook+0) and darker (mtShLook+4), easier to aim with
lis r12, mtShLook@ha
addi r12, r12, mtShLook@l
lfs f7, 0(r12)
lfs f8, 0(r11)
fmuls f8, f8, f7
stfs f8, 0(r11)
lfs f8, 4(r11)
fmuls f8, f8, f7
stfs f8, 4(r11)
lfs f8, 8(r11)
fmuls f8, f8, f7
stfs f8, 8(r11)
lfs f8, 32(r11)
fmuls f8, f8, f7
stfs f8, 32(r11)
lfs f8, 36(r11)
fmuls f8, f8, f7
stfs f8, 36(r11)
lfs f8, 40(r11)
fmuls f8, f8, f7
stfs f8, 40(r11)
lfs f7, 4(r12)
lfs f8, 0(r5)
fmuls f8, f8, f7
stfs f8, 8(r12)
lfs f8, 4(r5)
fmuls f8, f8, f7
stfs f8, 12(r12)
lfs f8, 8(r5)
fmuls f8, f8, f7
stfs f8, 16(r12)
lwz r0, 12(r5)
stw r0, 20(r12)
addi r5, r12, 8
mr r4, r11
mtShEllOrig:
stwu r1, -0x70(r1)
b mtShEllResume
0x0245A8EC = ba mtShEll
0x0245A2E4 = mtShCylResume:
mtShCyl:
; r4 = the mask's world matrix, r5 = &mask->Color (mask = r5 - 0x14), r6 = DrawCategory
cmpwi r6, 4
bne mtShCylOrig
lis r12, mtTurnKeep@ha
addi r12, r12, mtTurnKeep@l
; r8 = 1 while the body is drawn turned/moved (then the shadow goes with it), else 0
li r8, 1
lwz r0, 16(r12)
cmpwi r0, 0
bne mtShCylKeepOk
li r8, 0
mtShCylKeepOk:
lwz r9, 28(r12)
lis r10, mtHideModel@ha
addi r10, r10, mtHideModel@l
lwz r10, 12(r10)
subf r9, r9, r10
cmplwi r9, 2
ble mtShCylFresh
li r8, 0
mtShCylFresh:
; without the body turn the shadow is still made easier to see, in the original first person only
cmpwi r8, 0
bne mtShCylGo
lis r10, mtEyeBack@ha
lwz r0, mtEyeBack@l(r10)
cmpwi r0, 0
bne mtShCylOrig
lis r10, mtControl@ha
addi r10, r10, mtControl@l
lwz r0, 28(r10)
cmpwi r0, 1
bne mtShCylOrig
mtShCylGo:
lis r10, mtShStat@ha
addi r10, r10, mtShStat@l
lwz r9, 4(r10)
addi r9, r9, 1
stw r9, 4(r10)
lwz r11, -0x14(r5)
lis r10, 0x1000
cmplw r11, r10
blt mtShCylOrig
lis r10, 0x5000
cmplw r11, r10
bge mtShCylOrig
andi. r0, r11, 3
bne mtShCylOrig
; the player's costume actor itself, or a part actor whose model ([[+0x44]]+8) is captured
lis r10, mtHideHost@ha
lwz r0, mtHideHost@l(r10)
cmpw r0, r11
beq mtShCylMine
lwz r11, 0x44(r11)
lis r10, 0x1000
cmplw r11, r10
blt mtShCylOrig
lis r10, 0x5000
cmplw r11, r10
bge mtShCylOrig
andi. r0, r11, 3
bne mtShCylOrig
lwz r11, 0(r11)
lis r10, 0x1000
cmplw r11, r10
blt mtShCylOrig
lis r10, 0x5000
cmplw r11, r10
bge mtShCylOrig
andi. r0, r11, 3
bne mtShCylOrig
lwz r11, 8(r11)
lis r10, mtHideModel@ha
addi r10, r10, mtHideModel@l
lwz r9, 16(r10)
cmplwi r9, 17
bgt mtShCylOrig
addi r10, r10, 20
mtShCylFind:
cmpwi r9, 0
ble mtShCylOrig
lwz r0, 0(r10)
cmpw r0, r11
beq mtShCylMine
addi r10, r10, 4
addi r9, r9, -1
b mtShCylFind
mtShCylMine:
lis r10, mtShStat@ha
addi r10, r10, mtShStat@l
lwz r9, 8(r10)
addi r9, r9, 1
stw r9, 8(r10)
; the last matched mask's own position (diagnostics)
lwz r9, 12(r4)
stw r9, 12(r10)
lwz r9, 28(r4)
stw r9, 16(r10)
lwz r9, 44(r4)
stw r9, 20(r10)
; a copy of it, turned and moved exactly like the body (the submit copies it at once)
lis r11, mtShScratch@ha
addi r11, r11, mtShScratch@l
lwz r0, 0(r4)
stw r0, 0(r11)
lwz r0, 4(r4)
stw r0, 4(r11)
lwz r0, 8(r4)
stw r0, 8(r11)
lwz r0, 12(r4)
stw r0, 12(r11)
lwz r0, 16(r4)
stw r0, 16(r11)
lwz r0, 20(r4)
stw r0, 20(r11)
lwz r0, 24(r4)
stw r0, 24(r11)
lwz r0, 28(r4)
stw r0, 28(r11)
lwz r0, 32(r4)
stw r0, 32(r11)
lwz r0, 36(r4)
stw r0, 36(r11)
lwz r0, 40(r4)
stw r0, 40(r11)
lwz r0, 44(r4)
stw r0, 44(r11)
cmpwi r8, 0
beq mtShCylNoTurn
lfs f5, 0(r12)
lfs f6, 4(r12)
lfs f9, 8(r12)
lfs f10, 12(r12)
lfs f13, 20(r12)
lfs f0, 24(r12)
lfs f7, 0(r11)
lfs f8, 32(r11)
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
stfs f11, 0(r11)
stfs f12, 32(r11)
lfs f7, 4(r11)
lfs f8, 36(r11)
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
stfs f11, 4(r11)
stfs f12, 36(r11)
lfs f7, 8(r11)
lfs f8, 40(r11)
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
stfs f11, 8(r11)
stfs f12, 40(r11)
lfs f7, 12(r11)
lfs f8, 44(r11)
fsubs f7, f7, f9
fsubs f8, f8, f10
fmuls f11, f5, f7
fmuls f12, f6, f8
fadds f11, f11, f12
fmuls f12, f5, f8
fmuls f8, f6, f7
fsubs f12, f12, f8
fadds f11, f11, f13
fadds f12, f12, f0
stfs f11, 12(r11)
stfs f12, 44(r11)
mtShCylNoTurn:
; first person: the landing shadow a bit bigger (mtShLook+0) and darker (mtShLook+4), easier to aim with
lis r12, mtShLook@ha
addi r12, r12, mtShLook@l
lfs f7, 0(r12)
lfs f8, 0(r11)
fmuls f8, f8, f7
stfs f8, 0(r11)
lfs f8, 4(r11)
fmuls f8, f8, f7
stfs f8, 4(r11)
lfs f8, 8(r11)
fmuls f8, f8, f7
stfs f8, 8(r11)
lfs f8, 32(r11)
fmuls f8, f8, f7
stfs f8, 32(r11)
lfs f8, 36(r11)
fmuls f8, f8, f7
stfs f8, 36(r11)
lfs f8, 40(r11)
fmuls f8, f8, f7
stfs f8, 40(r11)
lfs f7, 4(r12)
lfs f8, 0(r5)
fmuls f8, f8, f7
stfs f8, 8(r12)
lfs f8, 4(r5)
fmuls f8, f8, f7
stfs f8, 12(r12)
lfs f8, 8(r5)
fmuls f8, f8, f7
stfs f8, 16(r12)
lwz r0, 12(r5)
stw r0, 20(r12)
addi r5, r12, 8
mr r4, r11
mtShCylOrig:
stwu r1, -0x70(r1)
b mtShCylResume
0x0245A2E0 = ba mtShCyl

; Hands. The game computes each glove's matrix from a joint of Mario's body and hands it
; to the setter at 0x024069A0. The three calls in that routine come here instead: for the
; two glove actors, in the original first person, the matrix becomes the controller's
; pose in the game world (also copied to the part's own copy at +0xB4); everything else
; goes on to the original setter untouched.
mtHandFinal:
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r12, 0(r11)
cmpwi r12, 0
beq mtHandOrig
lis r12, mtEyeBack@ha
lwz r12, mtEyeBack@l(r12)
cmpwi r12, 0
bne mtHandOrig
lis r12, mtControl@ha
addi r12, r12, mtControl@l
lwz r0, 28(r12)
cmpwi r0, 1
bne mtHandOrig
lwz r5, 4(r11)
cmpw r3, r5
bne mtHandNotL
li r10, 0
li r9, 16
b mtHandKnown
mtHandNotL:
lwz r5, 8(r11)
cmpw r3, r5
bne mtHandOrig
li r10, 1
li r9, 88
mtHandKnown:
lis r8, mtPad@ha
addi r8, r8, mtPad@l
add r6, r8, r9
lwz r0, 0(r6)
cmpwi r0, 1
bne mtHandOrig
lis r7, mtHandCam@ha
addi r7, r7, mtHandCam@l
lwz r0, 60(r7)
lwz r5, 64(r7)
cmpwi r0, 0
beq mtHandC1only
cmpwi r5, 0
beq mtHandC0only
lfs f10, 36(r7)
lfs f0, 48(r7)
fadds f10, f10, f0
lfs f11, 40(r7)
lfs f0, 52(r7)
fadds f11, f11, f0
lfs f12, 44(r7)
lfs f0, 56(r7)
fadds f12, f12, f0
lfs f0, 48(r12)
fmuls f10, f10, f0
fmuls f11, f11, f0
fmuls f12, f12, f0
fneg f10, f10
fneg f11, f11
fneg f12, f12
b mtHandCDone
mtHandC0only:
lfs f10, 36(r7)
lfs f11, 40(r7)
lfs f12, 44(r7)
b mtHandCDone
mtHandC1only:
cmpwi r5, 0
beq mtHandOrig
lfs f10, 48(r7)
lfs f11, 52(r7)
lfs f12, 56(r7)
mtHandCDone:
; d = controller - head, in tracking units; P = eye centre + scale * S * d
lfs f13, 52(r12)
lfs f0, 16(r6)
lfs f1, 4(r8)
fsubs f0, f0, f1
lfs f1, 32(r6)
lfs f2, 8(r8)
fsubs f1, f1, f2
lfs f2, 48(r6)
lfs f3, 12(r8)
fsubs f2, f2, f3
; Prediction. The glove is computed once per game frame from a controller sample that is a little
; old by the time it is drawn, so the hand position is moved ahead by its own movement since the
; previous frame, times mtHandCtl+48. A repeated call in the same frame (same sample) keeps the
; last movement; a jump beyond mtHandCtl+52 drops it.
lis r9, mtHandVel@ha
addi r9, r9, mtHandVel@l
mulli r5, r10, 32
add r9, r9, r5
lfs f5, 16(r6)
lfs f6, 32(r6)
lfs f7, 48(r6)
lwz r0, 12(r9)
cmpwi r0, 0
beq mtHandPredFirst
lfs f8, 0(r9)
fsubs f8, f5, f8
lfs f9, 4(r9)
fsubs f9, f6, f9
lfs f4, 8(r9)
fsubs f4, f7, f4
stfs f5, 0(r9)
stfs f6, 4(r9)
stfs f7, 8(r9)
fmuls f3, f8, f8
fmuls f5, f9, f9
fadds f3, f3, f5
fmuls f5, f4, f4
fadds f3, f3, f5
fsubs f5, f3, f3
.int 0xFC032800 ; fcmpu cr0, f3, f5
ble mtHandPredUse
lfs f5, 52(r11)
.int 0xFC032800 ; fcmpu cr0, f3, f5
bgt mtHandPredJump
stfs f8, 16(r9)
stfs f9, 20(r9)
stfs f4, 24(r9)
b mtHandPredUse
mtHandPredJump:
fsubs f5, f3, f3
stfs f5, 16(r9)
stfs f5, 20(r9)
stfs f5, 24(r9)
b mtHandPredUse
mtHandPredFirst:
stfs f5, 0(r9)
stfs f6, 4(r9)
stfs f7, 8(r9)
li r0, 1
stw r0, 12(r9)
b mtHandPredNone
mtHandPredUse:
lfs f5, 48(r11)
lfs f6, 16(r9)
fmuls f6, f6, f5
fadds f0, f0, f6
lfs f6, 20(r9)
fmuls f6, f6, f5
fadds f1, f1, f6
lfs f6, 24(r9)
fmuls f6, f6, f5
fadds f2, f2, f6
mtHandPredNone:
lfs f3, 0(r7)
fmuls f3, f3, f0
lfs f4, 4(r7)
fmuls f4, f4, f1
fadds f3, f3, f4
lfs f4, 8(r7)
fmuls f4, f4, f2
fadds f3, f3, f4
fmuls f3, f3, f13
fadds f3, f3, f10
stfs f3, 12(r4)
lfs f3, 12(r7)
fmuls f3, f3, f0
lfs f4, 16(r7)
fmuls f4, f4, f1
fadds f3, f3, f4
lfs f4, 20(r7)
fmuls f4, f4, f2
fadds f3, f3, f4
fmuls f3, f3, f13
fadds f3, f3, f11
stfs f3, 28(r4)
lfs f3, 24(r7)
fmuls f3, f3, f0
lfs f4, 28(r7)
fmuls f4, f4, f1
fadds f3, f3, f4
lfs f4, 32(r7)
fmuls f4, f4, f2
fadds f3, f3, f4
fmuls f3, f3, f13
fadds f3, f3, f12
stfs f3, 44(r4)
; Rw = S * (controller rotation), into the scratch
lfs f0, 0(r7)
lfs f1, 4(r6)
fmuls f0, f0, f1
lfs f1, 4(r7)
lfs f2, 20(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r7)
lfs f2, 36(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 68(r7)
lfs f0, 0(r7)
lfs f1, 8(r6)
fmuls f0, f0, f1
lfs f1, 4(r7)
lfs f2, 24(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r7)
lfs f2, 40(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 72(r7)
lfs f0, 0(r7)
lfs f1, 12(r6)
fmuls f0, f0, f1
lfs f1, 4(r7)
lfs f2, 28(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 8(r7)
lfs f2, 44(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 76(r7)
lfs f0, 12(r7)
lfs f1, 4(r6)
fmuls f0, f0, f1
lfs f1, 16(r7)
lfs f2, 20(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 20(r7)
lfs f2, 36(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 80(r7)
lfs f0, 12(r7)
lfs f1, 8(r6)
fmuls f0, f0, f1
lfs f1, 16(r7)
lfs f2, 24(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 20(r7)
lfs f2, 40(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 84(r7)
lfs f0, 12(r7)
lfs f1, 12(r6)
fmuls f0, f0, f1
lfs f1, 16(r7)
lfs f2, 28(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 20(r7)
lfs f2, 44(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 88(r7)
lfs f0, 24(r7)
lfs f1, 4(r6)
fmuls f0, f0, f1
lfs f1, 28(r7)
lfs f2, 20(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r7)
lfs f2, 36(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 92(r7)
lfs f0, 24(r7)
lfs f1, 8(r6)
fmuls f0, f0, f1
lfs f1, 28(r7)
lfs f2, 24(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r7)
lfs f2, 40(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 96(r7)
lfs f0, 24(r7)
lfs f1, 12(r6)
fmuls f0, f0, f1
lfs f1, 28(r7)
lfs f2, 28(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 32(r7)
lfs f2, 44(r6)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 100(r7)
; move the glove forward along the way the controller points (its -Z axis)
lfs f3, 44(r11)
lfs f0, 76(r7)
fmuls f0, f0, f3
lfs f1, 12(r4)
fsubs f1, f1, f0
stfs f1, 12(r4)
lfs f0, 88(r7)
fmuls f0, f0, f3
lfs f1, 28(r4)
fsubs f1, f1, f0
stfs f1, 28(r4)
lfs f0, 100(r7)
fmuls f0, f0, f3
lfs f1, 44(r4)
fsubs f1, f1, f0
stfs f1, 44(r4)
; the orientation preset of this hand
lwz r5, 64(r11)
mulli r5, r5, 52
mulli r0, r10, 4
add r5, r5, r0
add r5, r5, r11
lwz r5, 16(r5)
mulli r5, r5, 36
lis r9, mtHandOff@ha
addi r9, r9, mtHandOff@l
add r5, r5, r9
; W = Rw * preset, into the matrix the game is about to use
lfs f0, 68(r7)
lfs f1, 0(r5)
fmuls f0, f0, f1
lfs f1, 72(r7)
lfs f2, 12(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 76(r7)
lfs f2, 24(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 0(r4)
lfs f0, 68(r7)
lfs f1, 4(r5)
fmuls f0, f0, f1
lfs f1, 72(r7)
lfs f2, 16(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 76(r7)
lfs f2, 28(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 4(r4)
lfs f0, 68(r7)
lfs f1, 8(r5)
fmuls f0, f0, f1
lfs f1, 72(r7)
lfs f2, 20(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 76(r7)
lfs f2, 32(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 8(r4)
lfs f0, 80(r7)
lfs f1, 0(r5)
fmuls f0, f0, f1
lfs f1, 84(r7)
lfs f2, 12(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 88(r7)
lfs f2, 24(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 16(r4)
lfs f0, 80(r7)
lfs f1, 4(r5)
fmuls f0, f0, f1
lfs f1, 84(r7)
lfs f2, 16(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 88(r7)
lfs f2, 28(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 20(r4)
lfs f0, 80(r7)
lfs f1, 8(r5)
fmuls f0, f0, f1
lfs f1, 84(r7)
lfs f2, 20(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 88(r7)
lfs f2, 32(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 24(r4)
lfs f0, 92(r7)
lfs f1, 0(r5)
fmuls f0, f0, f1
lfs f1, 96(r7)
lfs f2, 12(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 100(r7)
lfs f2, 24(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 32(r4)
lfs f0, 92(r7)
lfs f1, 4(r5)
fmuls f0, f0, f1
lfs f1, 96(r7)
lfs f2, 16(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 100(r7)
lfs f2, 28(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 36(r4)
lfs f0, 92(r7)
lfs f1, 8(r5)
fmuls f0, f0, f1
lfs f1, 96(r7)
lfs f2, 20(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
lfs f1, 100(r7)
lfs f2, 32(r5)
fmuls f1, f1, f2
fadds f0, f0, f1
stfs f0, 40(r4)
; glove size: every axis of the glove's rotation is scaled
; Peach, Rosalina, Toad and their small forms have hand models about half of Mario's size (see mtGloveSize), so they get
; their own sizes, told by the model's vertex count: ResModel = [model + 0x24], total vertices at ResModel + 0x28
; (the models are the ones captured in mtHandCtl+36 / +40). Everything else keeps the two classes below.
lis r8, mtGloveSize@ha
addi r8, r8, mtGloveSize@l
lis r6, mtArmTmp@ha
addi r6, r6, mtArmTmp@l
lwz r0, 28(r8)
stw r0, 172(r6)
stw r0, 180(r6)
lfs f4, 52(r8)
lfs f5, 28(r8)
lfs f6, 84(r8)
stfs f6, 176(r6)
lfs f7, 88(r8)
stfs f7, 168(r6)
lwz r5, 64(r11)
lfs f0, 56(r11)
cmpwi r5, 0
beq mtGlvClass
lfs f0, 60(r11)
mtGlvClass:
lfs f1, 104(r8)
fmuls f1, f1, f0
lfs f2, 28(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
ble mtGlvThick
fmr f1, f2
mtGlvThick:
stfs f1, 172(r6)
mulli r5, r10, 4
add r5, r5, r11
lwz r5, 36(r5)
lis r0, 0x1000
cmplw r5, r0
blt mtHandSizeSet
lis r0, 0x5000
cmplw r5, r0
bge mtHandSizeSet
lwz r5, 0x24(r5)
lis r0, 0x1000
cmplw r5, r0
blt mtHandSizeSet
lis r0, 0x5000
cmplw r5, r0
bge mtHandSizeSet
lis r12, 0x464D
ori r12, r12, 0x444C
lwz r0, 0(r5)
cmpw r0, r12
bne mtHandSizeSet
lwz r5, 0x28(r5)
cmpwi r5, 2400
blt mtHandSizeSet
cmpwi r5, 3600
bgt mtHandSizeSet
lfs f1, 120(r6)
cmpwi r5, 3300
bge mtGlvToad
lfs f0, 0(r8)
lfs f3, 36(r8)
lfs f4, 56(r8)
lfs f6, 80(r8)
lfs f2, 8(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtGlvSet
lfs f2, 12(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
bge mtGlvSet
lfs f0, 4(r8)
lfs f3, 40(r8)
lfs f4, 60(r8)
lfs f6, 80(r8)
lfs f7, 100(r8)
b mtGlvSet
mtGlvToad:
lfs f0, 16(r8)
lfs f3, 44(r8)
lfs f4, 64(r8)
lfs f5, 76(r8)
lfs f6, 84(r8)
lfs f7, 92(r8)
lfs f2, 8(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
blt mtGlvSet
lfs f2, 20(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
bge mtGlvSet
lfs f0, 24(r8)
lfs f3, 48(r8)
lfs f4, 68(r8)
lfs f5, 28(r8)
lfs f6, 84(r8)
lfs f7, 96(r8)
mtGlvSet:
stfs f3, 172(r6)
stfs f5, 180(r6)
stfs f6, 176(r6)
stfs f7, 168(r6)
lfs f1, 56(r11)
lfs f2, 32(r8)
fmuls f1, f1, f2
fmuls f0, f0, f1
mtHandSizeSet:
; ... times the body model's own scale (1; bigger with the Mega Mushroom), mtEyeFit+56
lis r5, mtEyeFit@ha
addi r5, r5, mtEyeFit@l
lfs f1, 56(r5)
fmuls f0, f0, f1
; giant body: the gloves are a little smaller (mtEyeFit+76 at the most, reached at 1 + 1/(+80) times the normal size)
lfs f2, 40(r5)
fsubs f2, f1, f2
lfs f3, 80(r5)
fmuls f2, f2, f3
fsubs f3, f3, f3
.int 0xFC031000 ; fcmpu cr0, f3, f2
bge mtGlvNoGiant
lfs f3, 40(r5)
.int 0xFC021800 ; fcmpu cr0, f2, f3
ble mtGlvGiantT
fmr f2, f3
mtGlvGiantT:
lfs f3, 76(r5)
fmuls f2, f2, f3
lfs f3, 40(r5)
fsubs f3, f3, f2
fmuls f0, f0, f3
mtGlvNoGiant:
lfs f1, 0(r4)
fmuls f1, f1, f0
stfs f1, 0(r4)
lfs f1, 4(r4)
fmuls f1, f1, f0
stfs f1, 4(r4)
lfs f1, 8(r4)
fmuls f1, f1, f0
stfs f1, 8(r4)
lfs f1, 16(r4)
fmuls f1, f1, f0
stfs f1, 16(r4)
lfs f1, 20(r4)
fmuls f1, f1, f0
stfs f1, 20(r4)
lfs f1, 24(r4)
fmuls f1, f1, f0
stfs f1, 24(r4)
lfs f1, 32(r4)
fmuls f1, f1, f0
stfs f1, 32(r4)
lfs f1, 36(r4)
fmuls f1, f1, f0
stfs f1, 36(r4)
lfs f1, 40(r4)
fmuls f1, f1, f0
stfs f1, 40(r4)
; centring: the middle of the glove lies f4 glove units along its fingers (mtGloveSize+52..+68, times +72); the wrist is moved
; back by that along the fingers (the Z column, already scaled by the glove's size) so the middle of the hand sits on the
; controller's point (plus mtHandCtl+44). The vector the wrist was moved by is kept in mtHandShift for the carried object.
lfs f1, 72(r8)
fmuls f4, f4, f1
lis r5, mtHandShift@ha
addi r5, r5, mtHandShift@l
mulli r0, r10, 12
add r5, r5, r0
lfs f1, 8(r4)
fmuls f1, f1, f4
lfs f2, 12(r4)
fsubs f2, f2, f1
stfs f2, 12(r4)
fneg f1, f1
stfs f1, 0(r5)
lfs f1, 24(r4)
fmuls f1, f1, f4
lfs f2, 28(r4)
fsubs f2, f2, f1
stfs f2, 28(r4)
fneg f1, f1
stfs f1, 4(r5)
lfs f1, 40(r4)
fmuls f1, f1, f4
lfs f2, 44(r4)
fsubs f2, f2, f1
stfs f2, 44(r4)
fneg f1, f1
stfs f1, 8(r5)
addi r5, r3, 0xB4
lwz r0, 0(r4)
stw r0, 0(r5)
lwz r0, 4(r4)
stw r0, 4(r5)
lwz r0, 8(r4)
stw r0, 8(r5)
lwz r0, 12(r4)
stw r0, 12(r5)
lwz r0, 16(r4)
stw r0, 16(r5)
lwz r0, 20(r4)
stw r0, 20(r5)
lwz r0, 24(r4)
stw r0, 24(r5)
lwz r0, 28(r4)
stw r0, 28(r5)
lwz r0, 32(r4)
stw r0, 32(r5)
lwz r0, 36(r4)
stw r0, 36(r5)
lwz r0, 40(r4)
stw r0, 40(r5)
lwz r0, 44(r4)
stw r0, 44(r5)
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
mulli r5, r10, 48
add r5, r5, r9
lis r8, mtGlDbg@ha
addi r8, r8, mtGlDbg@l
mulli r0, r10, 12
add r8, r8, r0
lwz r0, 12(r5)
stw r0, 0(r8)
lwz r0, 28(r5)
stw r0, 4(r8)
lwz r0, 44(r5)
stw r0, 8(r8)
lis r12, mtGlDbg@ha
addi r12, r12, mtGlDbg@l
lwz r8, 64(r12)
add r6, r12, r8
addi r0, r10, 0x10
stb r0, 68(r6)
addi r8, r8, 1
andi. r8, r8, 63
stw r8, 64(r12)
lwz r0, 0(r4)
stw r0, 0(r5)
lwz r0, 4(r4)
stw r0, 4(r5)
lwz r0, 8(r4)
stw r0, 8(r5)
lwz r0, 12(r4)
stw r0, 12(r5)
lwz r0, 16(r4)
stw r0, 16(r5)
lwz r0, 20(r4)
stw r0, 20(r5)
lwz r0, 24(r4)
stw r0, 24(r5)
lwz r0, 28(r4)
stw r0, 28(r5)
lwz r0, 32(r4)
stw r0, 32(r5)
lwz r0, 36(r4)
stw r0, 36(r5)
lwz r0, 40(r4)
stw r0, 40(r5)
lwz r0, 44(r4)
stw r0, 44(r5)
cmpwi r10, 1
bne mtHandNoAim
lfs f0, 76(r7)
fneg f0, f0
stfs f0, 112(r9)
lfs f0, 88(r7)
fneg f0, f0
stfs f0, 116(r9)
lfs f0, 100(r7)
fneg f0, f0
stfs f0, 120(r9)
lis r5, mtFireStat@ha
addi r5, r5, mtFireStat@l
lwz r0, 4(r5)
stw r0, 32(r5)
mtHandNoAim:
mulli r5, r10, 4
add r5, r5, r9
li r0, 1
stw r0, 96(r5)
; the punch: this hand's glove is in place
mflr r0
stwu r1, -0x20(r1)
stw r0, 0x24(r1)
stw r3, 8(r1)
stw r4, 12(r1)
bl mtPunchHand
lwz r3, 8(r1)
lwz r4, 12(r1)
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
mtHandOrig:
b mtHandOriginalSet
0x024069A0 = mtHandOriginalSet:
0x0247EB5C = bla mtHandFinal
0x0247EBA8 = bla mtHandFinal
0x0247EC20 = bla mtHandFinal

; ---- Punch ----------------------------------------------------------------------------------------------------
; The director is caught where the sensor creation hands a new sensor to the group assignment (0x0244DD78): r3 = the director, r27 = the pool.
mtSensorSpy:
lis r12, mtPunch@ha
addi r12, r12, mtPunch@l
stw r3, 28(r12)
stw r27, 32(r12)
lwz r11, 44(r12)
addi r11, r11, 1
stw r11, 44(r12)
b mtGroupAssign
0x0240820C = bla mtSensorSpy
0x0244DD78 = mtGroupAssign:
; The message log: the dispatcher's first instruction (0x02409490, mr r6, r5) comes here with r3 = the message, r4 = the sender sensor, r5 = the receiver sensor.
mtMsgSpy:
lis r12, mtMsgLog@ha
addi r12, r12, mtMsgLog@l
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
lwz r6, 0(r3)
li r7, 255
lis r0, 0x1000
cmplw r5, r0
blt mtMsgNoRecv
lis r0, 0x5000
cmplw r5, r0
bge mtMsgNoRecv
andi. r0, r5, 3
bne mtMsgNoRecv
lwz r7, 4(r5)
mtMsgNoRecv:
li r8, 255
lis r0, 0x1000
cmplw r4, r0
blt mtMsgNoSend
lis r0, 0x5000
cmplw r4, r0
bge mtMsgNoSend
andi. r0, r4, 3
bne mtMsgNoSend
lwz r8, 4(r4)
mtMsgNoSend:
lwz r9, 4(r12)
addi r10, r12, 16
mtMsgFind:
cmpwi r9, 0
ble mtMsgNew
lwz r11, 0(r10)
cmpw r11, r6
bne mtMsgNext
lwz r11, 4(r10)
cmpw r11, r7
bne mtMsgNext
lwz r11, 8(r10)
cmpw r11, r8
bne mtMsgNext
lwz r11, 12(r10)
addi r11, r11, 1
stw r11, 12(r10)
b mtMsgDone
mtMsgNext:
addi r10, r10, 16
addi r9, r9, -1
b mtMsgFind
mtMsgNew:
lwz r9, 4(r12)
cmpwi r9, 48
bge mtMsgDone
stw r6, 0(r10)
stw r7, 4(r10)
stw r8, 8(r10)
li r11, 1
stw r11, 12(r10)
addi r9, r9, 1
stw r9, 4(r12)
mtMsgDone:
mr r6, r5
b mtMsgBack
0x02409490 = ba mtMsgSpy
0x02409494 = mtMsgBack:
; The game's own functions used below.
0x0227E4E0 = mtPunIsX:
0x02409B4C = mtPunSendSpin:
0x02409A98 = mtPunSendBody:
0x0240983C = mtPunSendFire:
0x02409568 = mtPunSendStomp:
; mtPunchHand: r10 = the hand (0 left, 1 right) whose glove matrix has just been stored in mtHandW; r3, r4 and LR are kept by the caller.
mtPunchHand:
mflr r0
stwu r1, -0x50(r1)
stw r0, 0x54(r1)
stmw r24, 0x28(r1)
lis r31, mtPunch@ha
addi r31, r31, mtPunch@l
mr r30, r10
lwz r8, 48(r31)
addi r8, r8, 1
stw r8, 48(r31)
lwz r0, 0(r31)
cmpwi r0, 0
beq mtPunOut
mulli r9, r30, 4
add r9, r9, r31
lwz r8, 36(r9)
cmpwi r8, 0
ble mtPunReady
addi r8, r8, -1
stw r8, 36(r9)
b mtPunOut
mtPunReady:
; the grip of this hand (mtPad: left block at +16, right at +88; +0 tracked, +52 the buttons, 32 = grip)
lis r8, mtPad@ha
addi r8, r8, mtPad@l
mulli r9, r30, 72
addi r9, r9, 16
add r9, r8, r9
lwz r0, 0(r9)
cmpwi r0, 1
bne mtPunOut
lwz r0, 52(r9)
andi. r0, r0, 32
beq mtPunOut
; the hand's speed, per step, in tracking units (mtHandVel, 32 bytes per hand: +12 known, +16.. the last movement)
lis r8, mtHandVel@ha
addi r8, r8, mtHandVel@l
mulli r0, r30, 32
add r8, r8, r0
lwz r0, 12(r8)
cmpwi r0, 0
beq mtPunOut
lfs f1, 16(r8)
lfs f2, 20(r8)
lfs f3, 24(r8)
fmuls f4, f1, f1
fmuls f5, f2, f2
fadds f4, f4, f5
fmuls f5, f3, f3
fadds f4, f4, f5
stfs f4, 96(r31)
lfs f5, 100(r31)
.int 0xFC042800 ; fcmpu cr0, f4, f5
ble mtPunNoPeak
stfs f4, 100(r31)
mtPunNoPeak:
lfs f5, 4(r31)
.int 0xFC042800 ; fcmpu cr0, f4, f5
blt mtPunOut
lwz r8, 52(r31)
addi r8, r8, 1
stw r8, 52(r31)
; the fist: the glove's place (mtHandW matrix, 48 bytes per hand, position at 12/28/44) a little ahead along its fingers (column 2 at 8/24/40)
lis r29, mtHandW@ha
addi r29, r29, mtHandW@l
mulli r0, r30, 48
add r29, r29, r0
lfs f10, 12(r29)
lfs f11, 28(r29)
lfs f12, 44(r29)
lfs f1, 92(r31)
lfs f2, 8(r29)
fmuls f2, f2, f1
fadds f10, f10, f2
lfs f2, 24(r29)
fmuls f2, f2, f1
fadds f11, f11, f2
lfs f2, 40(r29)
fmuls f2, f2, f1
fadds f12, f12, f2
lwz r28, 28(r31)
lis r0, 0x1000
cmplw r28, r0
blt mtPunNoDir
lis r0, 0x5000
cmplw r28, r0
bge mtPunNoDir
andi. r0, r28, 3
bne mtPunNoDir
li r25, 0
lfs f13, 104(r31)
li r24, 0
mtPunPass:
cmpwi r24, 0
bne mtPunPass2
lwz r6, 28(r31)
lwz r28, 28(r6)
b mtPunGroup
mtPunPass2:
lwz r6, 28(r31)
lwz r28, 20(r6)
mtPunGroup:
lis r0, 0x1000
cmplw r28, r0
blt mtPunNextPass
lis r0, 0x5000
cmplw r28, r0
bge mtPunNextPass
andi. r0, r28, 3
bne mtPunNextPass
lwz r27, 4(r28)
cmpwi r27, 0
ble mtPunNextPass
cmplwi r27, 4096
bgt mtPunNextPass
lwz r26, 8(r28)
lis r0, 0x1000
cmplw r26, r0
blt mtPunNextPass
lis r0, 0x5000
cmplw r26, r0
bge mtPunNextPass
andi. r0, r26, 3
bne mtPunNextPass
mtPunLoop:
cmpwi r27, 0
ble mtPunNextPass
lwz r5, 0(r26)
addi r26, r26, 4
addi r27, r27, -1
lis r0, 0x1000
cmplw r5, r0
blt mtPunLoop
lis r0, 0x5000
cmplw r5, r0
bge mtPunLoop
andi. r0, r5, 3
bne mtPunLoop
lbz r0, 0x28(r5)
cmpwi r0, 0
beq mtPunLoop
lbz r0, 0x29(r5)
cmpwi r0, 0
beq mtPunLoop
lwz r8, 56(r31)
addi r8, r8, 1
stw r8, 56(r31)
lwz r7, 4(r5)
lwz r6, 16(r31)
cmpw r7, r6
blt mtPunLoop
lwz r6, 20(r31)
cmpw r7, r6
bgt mtPunLoop
lwz r4, 0x2C(r5)
lis r0, 0x1000
cmplw r4, r0
blt mtPunLoop
lis r0, 0x5000
cmplw r4, r0
bge mtPunLoop
andi. r0, r4, 3
bne mtPunLoop
lwz r4, 0x7C(r4)
lis r0, 0x1000
cmplw r4, r0
blt mtPunLoop
lis r0, 0x5000
cmplw r4, r0
bge mtPunLoop
andi. r0, r4, 3
bne mtPunLoop
lbz r0, 0(r4)
cmpwi r0, 0
bne mtPunLoop
lfs f1, 8(r5)
fsubs f1, f1, f10
lfs f2, 12(r5)
fsubs f2, f2, f11
lfs f3, 16(r5)
fsubs f3, f3, f12
fmuls f1, f1, f1
fmuls f2, f2, f2
fadds f1, f1, f2
fmuls f2, f3, f3
fadds f1, f1, f2
lfs f4, 20(r5)
lfs f5, 8(r31)
fadds f4, f4, f5
fmuls f4, f4, f4
.int 0xFC012000 ; fcmpu cr0, f1, f4
bge mtPunLoop
lwz r8, 60(r31)
addi r8, r8, 1
stw r8, 60(r31)
.int 0xFC016800 ; fcmpu cr0, f1, f13
bge mtPunLoop
fmr f13, f1
mr r25, r5
b mtPunLoop
mtPunNextPass:
addi r24, r24, 1
cmpwi r24, 2
blt mtPunPass
cmpwi r25, 0
beq mtPunOut
stw r25, 76(r31)
lwz r0, 4(r25)
stw r0, 80(r31)
lwz r0, 0x2C(r25)
stw r0, 84(r31)
; Mario himself, and his 'SpinAttack' sensor (the player's sensors: [player+0x4C] -> +4 count, +8 array; a sensor's name is a pointer to the text)
lis r11, mtHideActor@ha
lwz r29, mtHideActor@l(r11)
lis r0, 0x1000
cmplw r29, r0
blt mtPunNoPlayer
lis r0, 0x5000
cmplw r29, r0
bge mtPunNoPlayer
andi. r0, r29, 3
bne mtPunNoPlayer
lwz r28, 0x4C(r29)
lis r0, 0x1000
cmplw r28, r0
blt mtPunNoPlayer
lis r0, 0x5000
cmplw r28, r0
bge mtPunNoPlayer
andi. r0, r28, 3
bne mtPunNoPlayer
lwz r27, 4(r28)
cmplwi r27, 32
bgt mtPunNoPlayer
lwz r26, 8(r28)
lis r0, 0x1000
cmplw r26, r0
blt mtPunNoPlayer
lis r0, 0x5000
cmplw r26, r0
bge mtPunNoPlayer
andi. r0, r26, 3
bne mtPunNoPlayer
li r24, 0
mtPunSndLoop:
cmpwi r27, 0
ble mtPunSndDone
lwz r5, 0(r26)
addi r26, r26, 4
addi r27, r27, -1
lis r0, 0x1000
cmplw r5, r0
blt mtPunSndLoop
lis r0, 0x5000
cmplw r5, r0
bge mtPunSndLoop
andi. r0, r5, 3
bne mtPunSndLoop
lwz r0, 0x2C(r5)
cmpw r0, r29
bne mtPunSndLoop
cmpwi r24, 0
bne mtPunSndHave
mr r24, r5
mtPunSndHave:
lwz r6, 0(r5)
lis r0, 0x1000
cmplw r6, r0
blt mtPunSndLoop
lis r0, 0x5000
cmplw r6, r0
bge mtPunSndLoop
andi. r0, r6, 3
bne mtPunSndLoop
lwz r7, 0(r6)
lis r8, 0x5370
ori r8, r8, 0x696E
cmpw r7, r8
bne mtPunSndLoop
lwz r7, 4(r6)
lis r8, 0x4174
ori r8, r8, 0x7461
cmpw r7, r8
bne mtPunSndLoop
lhz r7, 8(r6)
cmplwi r7, 0x636B
bne mtPunSndLoop
mr r24, r5
b mtPunSndDone
mtPunSndDone:
cmpwi r24, 0
beq mtPunNoSender
stw r24, 88(r31)
lwz r8, 64(r31)
addi r8, r8, 1
stw r8, 64(r31)
lwz r0, 24(r31)
mr r3, r25
mr r4, r24
cmpwi r0, 1
beq mtPunEffBody
cmpwi r0, 2
beq mtPunEffFire
cmpwi r0, 3
beq mtPunEffStomp
; 0: the spin attack, with the parameter the game picks at 0x0228B5C4
lwz r9, 0xC0(r29)
lis r0, 0x1000
cmplw r9, r0
blt mtPunSent
lis r0, 0x5000
cmplw r9, r0
bge mtPunSent
andi. r0, r9, 3
bne mtPunSent
lwz r3, 0x50(r9)
bl mtPunIsX
cmpwi r3, 0
lwz r5, 0x1F8(r29)
beq mtPunSpinGo
lwz r5, 0x1E8(r29)
mtPunSpinGo:
mr r3, r25
mr r4, r24
bl mtPunSendSpin
b mtPunSent
mtPunEffBody:
lwz r12, 0(r29)
lwz r0, 0x2FC(r12)
mtctr r0
mr r3, r29
bctrl
mr r5, r3
mr r3, r25
mr r4, r24
bl mtPunSendBody
b mtPunSent
mtPunEffFire:
bl mtPunSendFire
b mtPunSent
mtPunEffStomp:
lwz r12, 0(r29)
lwz r0, 0x2FC(r12)
mtctr r0
mr r3, r29
bctrl
mr r5, r3
mr r3, r25
mr r4, r24
bl mtPunSendStomp
b mtPunSent
mtPunSent:
cmpwi r3, 0
beq mtPunRefused
lwz r8, 68(r31)
addi r8, r8, 1
stw r8, 68(r31)
lwz r8, 12(r31)
mulli r9, r30, 4
add r9, r9, r31
stw r8, 36(r9)
lis r12, mtRumbleData@ha
addi r12, r12, mtRumbleData@l
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
li r11, 0
stw r11, 4(r12)
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
b mtPunOut
mtPunRefused:
lwz r8, 72(r31)
addi r8, r8, 1
stw r8, 72(r31)
li r8, 6
mulli r9, r30, 4
add r9, r9, r31
stw r8, 36(r9)
b mtPunOut
mtPunNoDir:
lwz r8, 108(r31)
addi r8, r8, 1
stw r8, 108(r31)
b mtPunOut
mtPunNoSender:
lwz r8, 112(r31)
addi r8, r8, 1
stw r8, 112(r31)
b mtPunOut
mtPunNoPlayer:
lwz r8, 116(r31)
addi r8, r8, 1
stw r8, 116(r31)
b mtPunOut
mtPunOut:
lmw r24, 0x28(r1)
lwz r0, 0x54(r1)
mtlr r0
addi r1, r1, 0x50
blr

; Thrown fireball, start position. The fireball's set-up routine (0x022AD6A0) asks for the joint
; 'HandR' of Mario's body (0x024025A0), then moves that point out of walls with its own sweep test,
; and only then uses it as the fireball's start. The call at 0x022AD6C8 comes here: it is made as
; before, and then, in the original first person with the right controller tracked, the point
; becomes the right glove's position. The sweep test and everything after it work on the glove's
; position, so a glove pushed into a wall does not start the fireball inside the wall. The
; counters in mtFireStat (see there) are for the launcher's summary.
mtFirePos:
bl mtFirePosOrig
lis r10, mtFireStat@ha
addi r10, r10, mtFireStat@l
lwz r12, 8(r10)
addi r12, r12, 1
stw r12, 8(r10)
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r12, 0(r11)
li r0, 1
cmpwi r12, 0
beq mtFirePosSkip
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
lwz r12, 104(r9)
li r0, 2
cmpwi r12, 0
beq mtFirePosSkip
lwz r12, 100(r9)
li r0, 3
cmpwi r12, 0
beq mtFirePosSkip
lis r12, mtEyeBack@ha
lwz r12, mtEyeBack@l(r12)
li r0, 4
cmpwi r12, 0
bne mtFirePosSkip
lis r12, mtControl@ha
addi r12, r12, mtControl@l
lwz r12, 28(r12)
li r0, 5
cmpwi r12, 1
bne mtFirePosSkip
lis r8, mtPad@ha
addi r8, r8, mtPad@l
lwz r12, 88(r8)
li r0, 6
cmpwi r12, 1
bne mtFirePosSkip
; the glove's origin is its wrist: the start is moved along the fingers (the glove's Z axis, column 2 of
; its matrix, which carries the glove's size) by mtHandCtl+76 glove units, to the middle of the palm
lfs f0, 76(r11)
lfs f1, 56(r9)
lfs f2, 60(r9)
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 0x24(r1)
stfs f1, 60(r10)
lfs f1, 72(r9)
lfs f2, 76(r9)
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 0x28(r1)
stfs f1, 64(r10)
lfs f1, 88(r9)
lfs f2, 92(r9)
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 0x2c(r1)
stfs f1, 68(r10)
lwz r12, 12(r10)
addi r12, r12, 1
stw r12, 12(r10)
; how old the glove's last update is, and how long ago X went down, in game frames
lwz r12, 4(r10)
lwz r0, 32(r10)
subf r0, r0, r12
stw r0, 36(r10)
lwz r8, 40(r10)
cmpw r0, r8
ble mtFirePosAgeMax
stw r0, 40(r10)
mtFirePosAgeMax:
lwz r0, 44(r10)
subf r0, r0, r12
stw r0, 48(r10)
lwz r8, 52(r10)
cmpw r0, r8
ble mtFirePosDelayMax
stw r0, 52(r10)
mtFirePosDelayMax:
lwz r12, 56(r10)
addi r12, r12, 1
stw r12, 56(r10)
b mtFirePosCont
mtFirePosSkip:
stw r0, 16(r10)
b mtFirePosCont
0x024025A0 = mtFirePosOrig:
0x022AD6CC = mtFirePosCont:
0x022AD6C8 = ba mtFirePos

; Diorama camera turning. The game's camera turns in steps (AngleHStep, 45 degrees) within limits
; (AngleHLimitMin / AngleHLimitMax: -45 / +45 by default, tighter or wider in some places), so the
; right stick stops turning the view at one side. Both parameter loaders - the default one, which
; comes here from 0x0241DD7C, and the per-area one, from 0x02421264 - do so once they have read
; their numbers, and the two horizontal limits become mtCam+4 / +8 (degrees). mtCam+0 = 0 leaves
; the game's own limits. (The displaced instruction is run at the end of each hook.)
mtCamParamsA:
lis r12, mtCam@ha
addi r12, r12, mtCam@l
lwz r0, 0(r12)
cmpwi r0, 0
beq mtCamParamsAOrig
lwz r11, 212(r27)
lis r0, 0x1000
cmplw r11, r0
blt mtCamParamsAOrig
lis r0, 0x5000
cmplw r11, r0
bge mtCamParamsAOrig
andi. r0, r11, 3
bne mtCamParamsAOrig
lfs f0, 4(r12)
stfs f0, 12(r11)
lfs f0, 8(r12)
stfs f0, 16(r11)
mtCamParamsAOrig:
lwz r3, 60(r27)
blr
0x0241DD7C = bla mtCamParamsA
mtCamParamsB:
lis r12, mtCam@ha
addi r12, r12, mtCam@l
lwz r0, 0(r12)
cmpwi r0, 0
beq mtCamParamsBOrig
lwz r11, 124(r30)
lis r0, 0x1000
cmplw r11, r0
blt mtCamParamsBOrig
lis r0, 0x5000
cmplw r11, r0
bge mtCamParamsBOrig
andi. r0, r11, 3
bne mtCamParamsBOrig
lfs f0, 4(r12)
stfs f0, 12(r11)
lfs f0, 8(r12)
stfs f0, 16(r11)
mtCamParamsBOrig:
lwz r0, 28(r1)
blr
0x02421264 = bla mtCamParamsB

; The player-moved cameras (the world map's, "UserMove"): their parameter blocks are built at 0x0242D858
; (and 0x0242B484, a smaller one of the same kind)
; with the horizontal turn limited to +45 / -45 degrees (+0xC / +0x10). Its last step (0x0242D8C4,
; lwz r0,0xc(r1); r3 = the block, 0 when it could not be made) comes here: with mtCam on, the
; limits become mtCam+8 / +4, so the right stick turns the map camera freely too.
mtUserMoveWide:
cmpwi r3, 0
beq mtUserMoveDone
lis r12, mtCam@ha
addi r12, r12, mtCam@l
lwz r0, 0(r12)
cmpwi r0, 0
beq mtUserMoveDone
lfs f0, 8(r12)
stfs f0, 0xC(r3)
lfs f0, 4(r12)
stfs f0, 0x10(r3)
mtUserMoveDone:
lwz r0, 0xc(r1)
blr
0x0242D8C4 = bla mtUserMoveWide
0x0242B4E4 = bla mtUserMoveWide


; Thrown fireball, direction. The set-up routine copies Mario's facing vector to 8(r1); the fireball's start
; velocity is that vector times the speed (minus Mario's up vector times a fall speed) and the
; fireball's axes are built from it. The instruction at 0x022AD6E8 (lwz r11, 0x6c(r10), the first one
; after the copy) comes here: in the original first person, with the right controller tracked, the
; vector becomes the direction the controller points, so the fireball flies where the hand aims, not
; where Mario faces. Mode 2 (default) keeps only the horizontal part of that direction, scaled back
; to length 1, so a hand held low or high does not throw the fireball into the floor; a hand pointing
; (almost) straight up or down leaves the game's own direction. Mode 1 uses the whole direction.
; r10 (the holder) and r1 must come out unchanged; r7 is the counters' base here.
mtFireDir:
lis r7, mtFireStat@ha
addi r7, r7, mtFireStat@l
lwz r12, 20(r7)
addi r12, r12, 1
stw r12, 20(r7)
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r12, 0(r11)
li r0, 1
cmpwi r12, 0
beq mtFireDirSkip
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
lwz r12, 108(r9)
li r0, 2
cmpwi r12, 0
beq mtFireDirSkip
lwz r12, 100(r9)
li r0, 3
cmpwi r12, 0
beq mtFireDirSkip
lis r12, mtEyeBack@ha
lwz r12, mtEyeBack@l(r12)
li r0, 4
cmpwi r12, 0
bne mtFireDirSkip
lis r12, mtControl@ha
addi r12, r12, mtControl@l
lwz r12, 28(r12)
li r0, 5
cmpwi r12, 1
bne mtFireDirSkip
lis r8, mtPad@ha
addi r8, r8, mtPad@l
lwz r12, 88(r8)
li r0, 6
cmpwi r12, 1
bne mtFireDirSkip
lwz r12, 108(r9)
cmpwi r12, 1
beq mtFireDirFull
lfs f0, 112(r9)
lfs f2, 120(r9)
fmuls f3, f0, f0
fmuls f4, f2, f2
fadds f3, f3, f4
lfs f4, 124(r9)
.int 0xFC032000 ; fcmpu cr0, f3, f4
blt mtFireDirVertical
; 1 / sqrt(x): the estimate, then one Newton step
.int 0xFC801834 ; frsqrte f4, f3
fmuls f5, f4, f4
fmuls f5, f5, f3
lfs f6, 128(r9)
fmuls f5, f5, f6
lfs f6, 132(r9)
fsubs f5, f6, f5
fmuls f4, f4, f5
fmuls f0, f0, f4
fmuls f2, f2, f4
stfs f0, 8(r1)
li r0, 0
stw r0, 12(r1)
stfs f2, 16(r1)
b mtFireDirDone
mtFireDirFull:
lwz r0, 112(r9)
stw r0, 8(r1)
lwz r0, 116(r9)
stw r0, 12(r1)
lwz r0, 120(r9)
stw r0, 16(r1)
mtFireDirDone:
lwz r0, 8(r1)
stw r0, 72(r7)
lwz r0, 12(r1)
stw r0, 76(r7)
lwz r0, 16(r1)
stw r0, 80(r7)
lwz r12, 24(r7)
addi r12, r12, 1
stw r12, 24(r7)
b mtFireDirOrig
mtFireDirVertical:
li r0, 7
mtFireDirSkip:
stw r0, 28(r7)
mtFireDirOrig:
lwz r11, 108(r10)
blr
0x022AD6E8 = bla mtFireDir

; Throwing what Mario carries (shell, baseball, snowball, Bob-omb, enemies...). The player's carry
; update (0x02291534) releases the held object by sending it one throw message (0x02409E90, r3 = the
; held object's sensor, r4 = the player's Body sensor, r31 = the player), at 0x02291680 (after the
; throw animation's countdown) and 0x02291730 (at once). Every object's handler reads the thrower's
; facing vector ([[player+0xC0]]+0xC) during that call. In the original first person, with the right
; controller tracked, the facing vector is set to where the controller points (on the ground plane,
; length 1) for the call only, then put back - so the object flies where the hand aims.
0x02409E90 = mtThrowMsg:
0x02291684 = mtThrowARet:
0x02291734 = mtThrowBRet:
mtThrowA:
bl mtThrowPre
bl mtThrowMsg
bl mtThrowPost
b mtThrowARet
0x02291680 = ba mtThrowA
mtThrowB:
bl mtThrowPre
bl mtThrowMsg
bl mtThrowPost
b mtThrowBRet
0x02291730 = ba mtThrowB
; r3 and r4 must come out unchanged
mtThrowPre:
lis r12, mtThrow@ha
addi r12, r12, mtThrow@l
li r0, 0
stw r0, 24(r12)
lwz r8, 32(r12)
addi r8, r8, 1
stw r8, 32(r12)
lis r10, mtHideActor@ha
lwz r0, mtHideActor@l(r10)
cmpw r0, r31
bne mtThrowPreDone
lis r12, mtThrow@ha
addi r12, r12, mtThrow@l
lwz r0, 0(r12)
cmpwi r0, 0
beq mtThrowPreDone
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r0, 0(r11)
cmpwi r0, 0
beq mtThrowPreDone
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
lwz r0, 100(r9)
cmpwi r0, 0
beq mtThrowPreDone
lis r10, mtEyeBack@ha
lwz r0, mtEyeBack@l(r10)
cmpwi r0, 0
bne mtThrowPreDone
lis r10, mtControl@ha
addi r10, r10, mtControl@l
lwz r0, 28(r10)
cmpwi r0, 1
bne mtThrowPreDone
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lwz r0, 88(r10)
cmpwi r0, 1
bne mtThrowPreDone
lfs f0, 112(r9)
lfs f2, 120(r9)
; mtThrow+44 = 1: straight ahead of the body (the tracking space's forward, turned with the stick)
lis r10, mtThrow@ha
addi r10, r10, mtThrow@l
lwz r0, 44(r10)
cmpwi r0, 0
beq mtThrowDirHand
mflr r12
bl mtHeadFwd
mtlr r12
fmr f0, f5
fmr f2, f6
; mtThrow+44 = 2: where the hand holding it points (its glove's fingers, on the ground plane - the
; arrow of the controller markers), left or right hand; pointing (almost) straight down keeps the
; head's facing
lis r11, mtThrow@ha
addi r11, r11, mtThrow@l
lwz r0, 44(r11)
cmpwi r0, 2
bne mtThrowDirHand
lis r11, mtGrabHand@ha
lwz r0, mtGrabHand@l(r11)
addi r11, r9, 48
cmpwi r0, 0
bne mtThrowHandGo
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r11, 4(r11)
lis r0, 0x1000
cmplw r11, r0
addi r11, r11, 0xB4
bge mtThrowHandGo
addi r11, r9, 48
mtThrowHandGo:
lfs f3, 8(r11)
lfs f4, 40(r11)
fmuls f5, f3, f3
fmuls f6, f4, f4
fadds f5, f5, f6
lfs f6, 124(r9)
.int 0xFC053000 ; fcmpu cr0, f5, f6
blt mtThrowDirHand
fmr f0, f3
fmr f2, f4
mtThrowDirHand:
fmuls f3, f0, f0
fmuls f4, f2, f2
fadds f3, f3, f4
lfs f4, 124(r9)
.int 0xFC032000 ; fcmpu cr0, f3, f4
blt mtThrowPreDone
.int 0xFC801834 ; frsqrte f4, f3
fmuls f5, f4, f4
fmuls f5, f5, f3
lfs f6, 128(r9)
fmuls f5, f5, f6
lfs f6, 132(r9)
fsubs f5, f6, f5
fmuls f4, f4, f5
fmuls f0, f0, f4
fmuls f2, f2, f4
lwz r10, 0xC0(r31)
lis r11, 0x1000
cmplw r10, r11
blt mtThrowPreDone
lis r11, 0x5000
cmplw r10, r11
bge mtThrowPreDone
andi. r0, r10, 3
bne mtThrowPreDone
lwz r10, 0(r10)
lis r11, 0x1000
cmplw r10, r11
blt mtThrowPreDone
lis r11, 0x5000
cmplw r10, r11
bge mtThrowPreDone
andi. r0, r10, 3
bne mtThrowPreDone
lis r12, mtThrow@ha
addi r12, r12, mtThrow@l
stw r10, 28(r12)
lwz r0, 12(r10)
stw r0, 12(r12)
lwz r0, 16(r10)
stw r0, 16(r12)
lwz r0, 20(r10)
stw r0, 20(r12)
stfs f0, 12(r10)
li r0, 0
stw r0, 16(r10)
stfs f2, 20(r10)
li r0, 1
stw r0, 24(r12)
lwz r8, 36(r12)
addi r8, r8, 1
stw r8, 36(r12)
mtThrowPreDone:
blr
mtThrowPost:
lis r12, mtThrow@ha
addi r12, r12, mtThrow@l
lwz r0, 24(r12)
cmpwi r0, 0
beq mtThrowPostDone
lwz r10, 28(r12)
lwz r0, 12(r12)
stw r0, 12(r10)
lwz r0, 16(r12)
stw r0, 16(r10)
lwz r0, 20(r12)
stw r0, 20(r10)
li r0, 0
stw r0, 24(r12)
mtThrowPostDone:
blr

; Where a carried object is held. While carried, its place is the middle of Mario's hands
; (0x022FF9A8 writes it to the vec3 at r30; r31 = the carrier's sensor, owner at +0x2C). The
; function's last step (0x022FFA58, lwz r0,0x54(r1)) comes here: in the original first person with
; the right controller tracked, the player's carried object sits in the right glove's palm instead,
; so it is thrown from your hand.
mtCarryPos:
mflr r7
lwz r11, 0x2C(r31)
lis r10, mtHideActor@ha
lwz r0, mtHideActor@l(r10)
cmpw r0, r11
beq mtCarryMine
lis r10, mtHideHost@ha
lwz r0, mtHideHost@l(r10)
cmpw r0, r11
bne mtCarryDone
mtCarryMine:
lis r12, mtThrow@ha
addi r12, r12, mtThrow@l
lwz r0, 4(r12)
cmpwi r0, 0
beq mtCarryDone
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r0, 0(r11)
cmpwi r0, 0
beq mtCarryDone
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
lwz r0, 100(r9)
cmpwi r0, 0
beq mtCarryDone
lis r10, mtEyeBack@ha
lwz r0, mtEyeBack@l(r10)
cmpwi r0, 0
bne mtCarryDone
lis r10, mtControl@ha
addi r10, r10, mtControl@l
lwz r0, 28(r10)
cmpwi r0, 1
bne mtCarryDone
lis r10, mtPad@ha
addi r10, r10, mtPad@l
mtCarryGlove:
; a touch pickup is held by the hands holding their grips: one hand -> that hand (the object moves
; over when you take it with the other grip and let go of the first), both -> between the hands,
; none -> the hand that had it last (mtGrab+20)
lis r8, mtGrab@ha
lwz r0, mtGrab@l(r8)
cmpwi r0, 0
beq mtCarryByGrip
bl mtCarryShrink
bl mtCarryFace
; mtThrow+48 = 2: held in front of the body, where the view is (moves with the camera settings,
; the eye height and the character's size), not in a hand
lwz r0, 48(r12)
cmpwi r0, 2
beq mtCarryFront
mtCarryFrontNo:
lis r10, mtPad@ha
addi r10, r10, mtPad@l
li r6, 0
lwz r0, 16(r10)
cmpwi r0, 1
bne mtCarryGripL
lwz r0, 68(r10)
andi. r0, r0, 32
beq mtCarryGripL
lwz r8, 4(r11)
lis r0, 0x1000
cmplw r8, r0
blt mtCarryGripL
ori r6, r6, 1
mtCarryGripL:
lwz r0, 88(r10)
cmpwi r0, 1
bne mtCarryGripR
lwz r0, 140(r10)
andi. r0, r0, 32
beq mtCarryGripR
ori r6, r6, 2
mtCarryGripR:
lis r8, mtGrabHand@ha
cmpwi r6, 3
beq mtCarryBoth
cmpwi r6, 1
bne mtCarryNotL
li r0, 0
stw r0, mtGrabHand@l(r8)
b mtCarryLeft
mtCarryNotL:
cmpwi r6, 2
bne mtCarryLast
li r0, 1
stw r0, mtGrabHand@l(r8)
b mtCarryRight
mtCarryLast:
lwz r0, mtGrabHand@l(r8)
cmpwi r0, 0
bne mtCarryRight
b mtCarryLeft
mtCarryFront:
; the eyes' middle + the head's facing x (mtThrow+52 + mtThrow+104) ahead, (mtThrow+56 +
; mtThrow+108) below, both times the character's size
lis r8, mtHandCam@ha
addi r8, r8, mtHandCam@l
lwz r0, 60(r8)
cmpwi r0, 0
beq mtCarryFrontNo
lwz r0, 64(r8)
cmpwi r0, 0
beq mtCarryFrontNo
bl mtHeadFwd
bl mtCarrySize
lis r8, mtHandCam@ha
addi r8, r8, mtHandCam@l
lfs f4, 60(r12)
lfs f7, 52(r12)
lfs f3, 104(r12)
fadds f7, f7, f3
fmuls f7, f7, f9
lfs f1, 36(r8)
lfs f2, 48(r8)
fadds f1, f1, f2
fmuls f1, f1, f4
fmuls f2, f5, f7
fadds f1, f1, f2
stfs f1, 0(r30)
lfs f1, 40(r8)
lfs f2, 52(r8)
fadds f1, f1, f2
fmuls f1, f1, f4
lfs f2, 56(r12)
lfs f3, 108(r12)
fadds f2, f2, f3
fmuls f2, f2, f9
fsubs f1, f1, f2
stfs f1, 4(r30)
lfs f1, 44(r8)
lfs f2, 56(r8)
fadds f1, f1, f2
fmuls f1, f1, f4
fmuls f2, f6, f7
fadds f1, f1, f2
stfs f1, 8(r30)
lwz r8, 40(r12)
addi r8, r8, 1
stw r8, 40(r12)
stw r30, 92(r12)
lwz r0, 0(r30)
stw r0, 116(r12)
lwz r0, 4(r30)
stw r0, 120(r12)
lwz r0, 8(r30)
stw r0, 124(r12)
b mtCarryDone
mtCarryBoth:
; both grips: the reach placement from between the two wrists
lwz r8, 4(r11)
addi r8, r8, 0xB4
lfs f3, 60(r12)
lfs f10, 12(r8)
lfs f1, 60(r9)
fadds f10, f10, f1
fmuls f10, f10, f3
lfs f11, 28(r8)
lfs f1, 76(r9)
fadds f11, f11, f1
fmuls f11, f11, f3
lfs f12, 44(r8)
lfs f1, 92(r9)
fadds f12, f12, f1
fmuls f12, f12, f3
; the wrists as they were before the centring (mtHandShift)
lis r8, mtHandShift@ha
addi r8, r8, mtHandShift@l
lfs f1, 0(r8)
lfs f2, 12(r8)
fadds f1, f1, f2
fmuls f1, f1, f3
fsubs f10, f10, f1
lfs f1, 4(r8)
lfs f2, 16(r8)
fadds f1, f1, f2
fmuls f1, f1, f3
fsubs f11, f11, f1
lfs f1, 8(r8)
lfs f2, 20(r8)
fadds f1, f1, f2
fmuls f1, f1, f3
fsubs f12, f12, f1
; mtCarryReach: the hand point W (f10, f11, f12) -> where the object goes: seen from the eyes, the
; hand's reach is stretched mtThrow+112 times on the level (arm out = far ahead, hand in = close),
; plus mtThrow+52 ahead along the head's facing; its height is the hand's minus mtThrow+56. The
; distances grow with the character's size.
mtCarryReach:
bl mtHeadFwd
bl mtCarrySize
lis r8, mtHandCam@ha
addi r8, r8, mtHandCam@l
fmr f1, f10
fmr f3, f12
lwz r0, 60(r8)
cmpwi r0, 0
beq mtReachGo
lwz r0, 64(r8)
cmpwi r0, 0
beq mtReachGo
lfs f4, 60(r12)
lfs f1, 36(r8)
lfs f2, 48(r8)
fadds f1, f1, f2
fmuls f1, f1, f4
lfs f3, 44(r8)
lfs f2, 56(r8)
fadds f3, f3, f2
fmuls f3, f3, f4
mtReachGo:
lfs f4, 112(r12)
lfs f7, 52(r12)
fmuls f7, f7, f9
fsubs f8, f10, f1
fmuls f8, f8, f4
fadds f8, f8, f1
fmuls f2, f5, f7
fadds f8, f8, f2
stfs f8, 0(r30)
lfs f2, 56(r12)
fmuls f2, f2, f9
fsubs f8, f11, f2
stfs f8, 4(r30)
fsubs f8, f12, f3
fmuls f8, f8, f4
fadds f8, f8, f3
fmuls f2, f6, f7
fadds f8, f8, f2
stfs f8, 8(r30)
lwz r8, 40(r12)
addi r8, r8, 1
stw r8, 40(r12)
stw r30, 92(r12)
lwz r0, 0(r30)
stw r0, 116(r12)
lwz r0, 4(r30)
stw r0, 120(r12)
lwz r0, 8(r30)
stw r0, 124(r12)
b mtCarryDone
mtCarryByGrip:
; otherwise the left glove when only its grip is held (and it is tracked), else the right one
lwz r0, 16(r10)
cmpwi r0, 1
bne mtCarryRight
lwz r0, 68(r10)
andi. r0, r0, 32
beq mtCarryRight
lwz r0, 140(r10)
andi. r0, r0, 32
bne mtCarryRight
mtCarryLeft:
lwz r0, 16(r10)
cmpwi r0, 1
bne mtCarryRight
lwz r8, 4(r11)
lis r0, 0x1000
cmplw r8, r0
blt mtCarryRight
addi r9, r8, 0xB4
li r5, 1
b mtCarryPlace
mtCarryRight:
lwz r0, 88(r10)
cmpwi r0, 1
bne mtCarryDone
addi r9, r9, 48
li r5, 0
mtCarryPlace:
; mtThrow+48 = 1: the object follows the hand's reach (mtCarryReach from its wrist); 0 = along the
; glove's fingers
lwz r0, 48(r12)
cmpwi r0, 0
beq mtCarryFingers
lfs f10, 12(r9)
lfs f11, 28(r9)
lfs f12, 44(r9)
; the wrist as it was before the centring (mtHandShift; r5 = 1 left, 0 right)
lis r8, mtHandShift@ha
addi r8, r8, mtHandShift@l
cmpwi r5, 1
beq mtCarryShL
addi r8, r8, 12
mtCarryShL:
lfs f1, 0(r8)
fsubs f10, f10, f1
lfs f1, 4(r8)
fsubs f11, f11, f1
lfs f1, 8(r8)
fsubs f12, f12, f1
b mtCarryReach
mtCarryFingers:
; r9 = the glove's 3x4 world matrix: its Z column (the fingers, carrying the glove size) at 8/24/40,
; the wrist at 12/28/44; the object goes (mtHandCtl+76 + mtThrow+8) glove units along the fingers
lfs f0, 76(r11)
lfs f3, 8(r12)
fadds f0, f0, f3
lis r8, mtHandShift@ha
addi r8, r8, mtHandShift@l
cmpwi r5, 1
beq mtCarryFgL
addi r8, r8, 12
mtCarryFgL:
lfs f1, 8(r9)
lfs f2, 12(r9)
lfs f3, 0(r8)
fsubs f2, f2, f3
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 0(r30)
lfs f1, 24(r9)
lfs f2, 28(r9)
lfs f3, 4(r8)
fsubs f2, f2, f3
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 4(r30)
lfs f1, 40(r9)
lfs f2, 44(r9)
lfs f3, 8(r8)
fsubs f2, f2, f3
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 8(r30)
lwz r8, 40(r12)
addi r8, r8, 1
stw r8, 40(r12)
stw r30, 92(r12)
lwz r0, 0(r30)
stw r0, 116(r12)
lwz r0, 4(r30)
stw r0, 120(r12)
lwz r0, 8(r30)
stw r0, 124(r12)
mtCarryDone:
mtlr r7
lwz r0, 0x54(r1)
blr
0x022FFA58 = bla mtCarryPos

; mtCarryShrink: the object picked up by grip is drawn smaller while held: its pose's scale
; (found once as the first (1, 1, 1) triple in its pose keeper [owner+0xC0], kept in
; mtGrab+32) is set to mtGrab+36 every frame; mtGrabHold puts 1 back when it is let go.
; Uses r0, r6, r8, r10 and f1..f4 only.
mtCarryShrink:
lis r8, mtGrab@ha
addi r8, r8, mtGrab@l
lfs f4, 40(r8)
lfs f1, 36(r8)
.int 0xFC012000 ; fcmpu cr0, f1, f4
beq mtShrinkDone
lwz r6, 32(r8)
cmpwi r6, 0
bne mtShrinkWrite
lwz r6, 0(r8)
lis r0, 0x1000
cmplw r6, r0
blt mtShrinkDone
lis r0, 0x5000
cmplw r6, r0
bge mtShrinkDone
andi. r0, r6, 3
bne mtShrinkDone
lwz r6, 0x2C(r6)
lis r0, 0x1000
cmplw r6, r0
blt mtShrinkDone
lis r0, 0x5000
cmplw r6, r0
bge mtShrinkDone
andi. r0, r6, 3
bne mtShrinkDone
lwz r6, 0xC0(r6)
lis r0, 0x1000
cmplw r6, r0
blt mtShrinkDone
lis r0, 0x5000
cmplw r6, r0
bge mtShrinkDone
andi. r0, r6, 3
bne mtShrinkDone
; r6 = the object's pose keeper [owner+0xC0] (a vtable, then its vectors): its scale is the first
; (1, 1, 1) triple in +4 .. +0x4C
mr r10, r6
addi r0, r6, 0x48
addi r6, r6, 4
mtShrinkScan:
lfs f1, 0(r6)
lfs f2, 4(r6)
lfs f3, 8(r6)
.int 0xFC012000 ; fcmpu cr0, f1, f4
bne mtShrinkNext
.int 0xFC022000 ; fcmpu cr0, f2, f4
bne mtShrinkNext
.int 0xFC032000 ; fcmpu cr0, f3, f4
beq mtShrinkFound
mtShrinkNext:
addi r6, r6, 4
cmplw r6, r0
blt mtShrinkScan
b mtShrinkDone
mtShrinkFound:
stw r6, 32(r8)
mtShrinkWrite:
lfs f1, 36(r8)
stfs f1, 0(r6)
stfs f1, 4(r6)
stfs f1, 8(r6)
mtShrinkDone:
blr

; mtCarryFace: while something is held by grip and Mario stands (left stick below mtThrow+100,
; squared), Mario really faces where the head looks (mtHeadFwd): the game turns and places what he
; carries by his facing, so the held object turns with the head and with the right-stick turning.
; Walking leaves the facing to the game (it steers by it). Uses r0, r6, r8, r10 and f1..f8.
mtCarryFace:
lis r8, mtThrow@ha
addi r8, r8, mtThrow@l
lwz r0, 96(r8)
cmpwi r0, 0
beq mtCarryFaceDone
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lfs f1, 80(r10)
lfs f2, 84(r10)
fmuls f1, f1, f1
fmuls f2, f2, f2
fadds f1, f1, f2
lfs f2, 100(r8)
.int 0xFC011000 ; fcmpu cr0, f1, f2
bge mtCarryFaceDone
mflr r6
bl mtHeadFwd
mtlr r6
lis r8, mtHideActor@ha
lwz r8, mtHideActor@l(r8)
lis r0, 0x1000
cmplw r8, r0
blt mtCarryFaceDone
lis r0, 0x5000
cmplw r8, r0
bge mtCarryFaceDone
andi. r0, r8, 3
bne mtCarryFaceDone
lwz r8, 0xC0(r8)
lis r0, 0x1000
cmplw r8, r0
blt mtCarryFaceDone
lis r0, 0x5000
cmplw r8, r0
bge mtCarryFaceDone
andi. r0, r8, 3
bne mtCarryFaceDone
lwz r8, 0(r8)
lis r0, 0x1000
cmplw r8, r0
blt mtCarryFaceDone
lis r0, 0x5000
cmplw r8, r0
bge mtCarryFaceDone
andi. r0, r8, 3
bne mtCarryFaceDone
stfs f5, 12(r8)
li r0, 0
stw r0, 16(r8)
stfs f6, 20(r8)
mtCarryFaceDone:
blr

; mtCarrySize: f9 = the character's size for the carried object's offsets = its eye height
; (mrEyeTarget+12) / 145, kept within mtThrow+72 .. +76. Uses r8, f3 and f9 only.
mtCarrySize:
lis r8, mrEyeTarget@ha
addi r8, r8, mrEyeTarget@l
lfs f9, 12(r8)
lfs f3, 68(r12)
fmuls f9, f9, f3
lfs f3, 72(r12)
.int 0xFC091800 ; fcmpu cr0, f9, f3
bge mtCarrySizeLo
fmr f9, f3
mtCarrySizeLo:
lfs f3, 76(r12)
.int 0xFC091800 ; fcmpu cr0, f9, f3
ble mtCarrySizeHi
fmr f9, f3
mtCarrySizeHi:
blr

; mtHeadFwd: (f5, f6) = where the head faces on the ground plane (x, z, length 1), from the two
; eyes (the vector between them turned a quarter to the front; the order of the eyes in mtHandCam was
; found the other way round on 02/10, the result had been pointing backward); the tracking space's
; forward when an eye is missing. Uses r0, r8, r10 and f1..f8 only.
mtHeadFwd:
lis r10, mtHandCam@ha
addi r10, r10, mtHandCam@l
lfs f5, 8(r10)
fneg f5, f5
lfs f6, 32(r10)
fneg f6, f6
lwz r0, 60(r10)
cmpwi r0, 0
beq mtHeadFwdDone
lwz r0, 64(r10)
cmpwi r0, 0
beq mtHeadFwdDone
lfs f7, 44(r10)
lfs f3, 56(r10)
fsubs f7, f7, f3
lfs f8, 48(r10)
lfs f3, 36(r10)
fsubs f8, f8, f3
fmuls f3, f7, f7
fmuls f4, f8, f8
fadds f3, f3, f4
lis r8, mtHandW@ha
addi r8, r8, mtHandW@l
lfs f4, 124(r8)
.int 0xFC032000 ; fcmpu cr0, f3, f4
blt mtHeadFwdDone
.int 0xFC801834 ; frsqrte f4, f3
fmuls f1, f4, f4
fmuls f1, f1, f3
lfs f2, 128(r8)
fmuls f1, f1, f2
lfs f2, 132(r8)
fsubs f1, f2, f1
fmuls f4, f4, f1
fmuls f1, f4, f4
fmuls f1, f1, f3
lfs f2, 128(r8)
fmuls f1, f1, f2
lfs f2, 132(r8)
fsubs f1, f2, f1
fmuls f4, f4, f1
fmuls f5, f7, f4
fmuls f6, f8, f4
mtHeadFwdDone:
blr

; The player's effects (dust, grass, splashes, sparkles...) when the body is drawn somewhere else in
; first person (turned with the view / standing under the pulled-back view, mtTurnKeep): every
; actor effect goes through the game's effect objects, whose emitter sets carry two world matrices
; (es+0x1E8 and es+0x218, 3x4, translation in the 4th column). The player's own effects (the
; EffectKeepers at +0x54 of the costume actor and of the player object) get the same turn and move
; as the body: once when an emitter is created (0x0251B2E8, the end of the create routine) and every
; frame for effects that follow a joint or position (the keeper update's call at 0x02447C20).
; Footprints and paw prints are pooled model actors placed once (0x0247BE7C): moved the same way.
0x0251CA14 = mtFxAlive:
0x0251A988 = mtFxUpdate:
; r3 = a 3x4 matrix, r4 bits: 1 = turn its axes (rows 0 and 2 of columns 0..2), 2 = move its
; translation (x at +12, z at +44). Uses r0, r11, r12, f0..f8 only.
mtFxXf:
lis r12, mtTurnKeep@ha
addi r12, r12, mtTurnKeep@l
lfs f5, 0(r12)
lfs f6, 4(r12)
andi. r0, r4, 1
beq mtFxXfMove
lfs f1, 0(r3)
lfs f2, 32(r3)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f0, f6, f1
fsubs f4, f4, f0
stfs f3, 0(r3)
stfs f4, 32(r3)
lfs f1, 4(r3)
lfs f2, 36(r3)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f0, f6, f1
fsubs f4, f4, f0
stfs f3, 4(r3)
stfs f4, 36(r3)
lfs f1, 8(r3)
lfs f2, 40(r3)
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f0, f6, f1
fsubs f4, f4, f0
stfs f3, 8(r3)
stfs f4, 40(r3)
mtFxXfMove:
andi. r0, r4, 2
beq mtFxXfDone
lfs f1, 12(r3)
lfs f2, 44(r3)
mflr r0
mr r11, r0
bl mtFxTurnPoint
mtlr r11
stfs f3, 12(r3)
stfs f4, 44(r3)
mtFxXfDone:
blr
; r3 = a vec3: its x (+0) and z (+8) turned and moved
mtFxVec:
lis r12, mtTurnKeep@ha
addi r12, r12, mtTurnKeep@l
lfs f5, 0(r12)
lfs f6, 4(r12)
lfs f1, 0(r3)
lfs f2, 8(r3)
mflr r0
mr r11, r0
bl mtFxTurnPoint
mtlr r11
stfs f3, 0(r3)
stfs f4, 8(r3)
blr
; (f1, f2) = a point's x, z -> (f3, f4) turned about (Tx, Tz) and moved to (Nx, Nz); r12 = mtTurnKeep
mtFxTurnPoint:
lfs f7, 8(r12)
lfs f8, 12(r12)
fsubs f1, f1, f7
fsubs f2, f2, f8
fmuls f3, f5, f1
fmuls f4, f6, f2
fadds f3, f3, f4
fmuls f4, f5, f2
fmuls f0, f6, f1
fsubs f4, f4, f0
lfs f7, 20(r12)
lfs f8, 24(r12)
fadds f3, f3, f7
fadds f4, f4, f8
blr
; creation: the end of the effect object's create routine (r30 = effect, r31 = handle)
mtFxEmit:
lis r12, mtTurnKeep@ha
addi r12, r12, mtTurnKeep@l
lwz r0, 16(r12)
cmpwi r0, 0
beq mtFxEmitOut
lwz r5, 28(r12)
lis r6, mtHideModel@ha
addi r6, r6, mtHideModel@l
lwz r6, 12(r6)
subf r5, r5, r6
cmplwi r5, 2
bgt mtFxEmitOut
lis r6, mtFx@ha
lwz r0, mtFx@l(r6)
cmpwi r0, 0
beq mtFxEmitOut
; the effect must belong to one of the player's two keepers
li r9, 0
lis r7, mtHideHost@ha
lwz r7, mtHideHost@l(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxEmitK2
lis r11, 0x5000
cmplw r7, r11
bge mtFxEmitK2
andi. r0, r7, 3
bne mtFxEmitK2
lwz r7, 0x54(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxEmitK2
lis r11, 0x5000
cmplw r7, r11
bge mtFxEmitK2
andi. r0, r7, 3
bne mtFxEmitK2
mr r3, r7
bl mtFxOwned
cmpwi r3, 0
bne mtFxEmitMine
mtFxEmitK2:
lis r7, mtHideActor@ha
lwz r7, mtHideActor@l(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxEmitOut
lis r11, 0x5000
cmplw r7, r11
bge mtFxEmitOut
andi. r0, r7, 3
bne mtFxEmitOut
lwz r7, 0x54(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxEmitOut
lis r11, 0x5000
cmplw r7, r11
bge mtFxEmitOut
andi. r0, r7, 3
bne mtFxEmitOut
mr r3, r7
bl mtFxOwned
cmpwi r3, 0
beq mtFxEmitOut
mtFxEmitMine:
mr r3, r31
bl mtFxAlive
cmpwi r3, 0
beq mtFxEmitOut
lwz r7, 4(r31)
lwz r7, 0(r7)
lwz r6, 0xC(r30)
lbz r0, 0x4A(r6)
li r4, 3
cmpwi r0, 0
beq mtFxEmitMode
li r4, 2
mtFxEmitMode:
addi r3, r7, 0x1E8
bl mtFxXf
addi r3, r7, 0x218
bl mtFxXf
lis r12, mtFx@ha
addi r12, r12, mtFx@l
lwz r8, 8(r12)
addi r8, r8, 1
stw r8, 8(r12)
mtFxEmitOut:
lwz r28, 8(r1)
b mtFxEmitRet
0x0251B2EC = mtFxEmitRet:
0x0251B2E8 = ba mtFxEmit
; r3 = keeper, r30 = effect: r3 = 1 when the effect is one of the keeper's (uses r0, r5, r6, r8)
mtFxOwned:
lwz r5, 4(r3)
cmplwi r5, 400
bgt mtFxOwnedNo
lwz r6, 8(r3)
lis r8, 0x1000
cmplw r6, r8
blt mtFxOwnedNo
lis r8, 0x5000
cmplw r6, r8
bge mtFxOwnedNo
mtFxOwnedLoop:
cmpwi r5, 0
ble mtFxOwnedNo
lwz r0, 0(r6)
cmpw r0, r30
beq mtFxOwnedYes
addi r6, r6, 4
addi r5, r5, -1
b mtFxOwnedLoop
mtFxOwnedYes:
li r3, 1
blr
mtFxOwnedNo:
li r3, 0
blr

; every frame: the keeper update's per-effect call (r3 = effect; r31 = the keeper, kept)
mtFxFollow:
mflr r0
stwu r1, -0x20(r1)
stw r0, 0x24(r1)
stw r3, 8(r1)
bl mtFxUpdate
stw r3, 12(r1)
lis r12, mtTurnKeep@ha
addi r12, r12, mtTurnKeep@l
lwz r0, 16(r12)
cmpwi r0, 0
beq mtFxFollowOut
lwz r5, 28(r12)
lis r6, mtHideModel@ha
addi r6, r6, mtHideModel@l
lwz r6, 12(r6)
subf r5, r5, r6
cmplwi r5, 2
bgt mtFxFollowOut
lis r6, mtFx@ha
lwz r0, mtFx@l(r6)
cmpwi r0, 0
beq mtFxFollowOut
lis r7, mtHideHost@ha
lwz r7, mtHideHost@l(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxFollowK2
lis r11, 0x5000
cmplw r7, r11
bge mtFxFollowK2
andi. r0, r7, 3
bne mtFxFollowK2
lwz r7, 0x54(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxFollowK2
lis r11, 0x5000
cmplw r7, r11
bge mtFxFollowK2
andi. r0, r7, 3
bne mtFxFollowK2
cmpw r7, r31
beq mtFxFollowMine
mtFxFollowK2:
lis r7, mtHideActor@ha
lwz r7, mtHideActor@l(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxFollowOut
lis r11, 0x5000
cmplw r7, r11
bge mtFxFollowOut
andi. r0, r7, 3
bne mtFxFollowOut
lwz r7, 0x54(r7)
lis r11, 0x1000
cmplw r7, r11
blt mtFxFollowOut
lis r11, 0x5000
cmplw r7, r11
bge mtFxFollowOut
andi. r0, r7, 3
bne mtFxFollowOut
cmpw r7, r31
bne mtFxFollowOut
mtFxFollowMine:
lwz r5, 8(r1)
lwz r6, 0xC(r5)
lis r11, 0x1000
cmplw r6, r11
blt mtFxFollowOut
lis r11, 0x5000
cmplw r6, r11
bge mtFxFollowOut
andi. r0, r6, 3
bne mtFxFollowOut
; follows a matrix (and no billboard): turn + move; follows a position or billboards: move only
lbz r0, 0x4D(r6)
lbz r8, 0x4C(r6)
add r8, r8, r0
cmpwi r8, 0
beq mtFxFollowOut
li r4, 2
cmpwi r0, 0
beq mtFxFollowMode
lbz r0, 0x4A(r6)
cmpwi r0, 0
bne mtFxFollowMode
li r4, 3
mtFxFollowMode:
lwz r6, 4(r5)
lwz r7, 8(r5)
cmplwi r7, 16
bgt mtFxFollowOut
mtFxFollowLoop:
cmpwi r7, 0
ble mtFxFollowOut
lwz r3, 0(r6)
bl mtFxAlive
cmpwi r3, 0
beq mtFxFollowNext
lwz r3, 0(r6)
lwz r3, 4(r3)
lwz r10, 0(r3)
addi r3, r10, 0x1E8
bl mtFxXf
addi r3, r10, 0x218
bl mtFxXf
lis r12, mtFx@ha
addi r12, r12, mtFx@l
lwz r8, 12(r12)
addi r8, r8, 1
stw r8, 12(r12)
mtFxFollowNext:
addi r6, r6, 4
addi r7, r7, -1
b mtFxFollowLoop
mtFxFollowOut:
lwz r3, 12(r1)
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
blr
0x02447C20 = bla mtFxFollow

; footprints / paw prints (only the player's code places them): their rotation (r1+0x188) and
; place (r1+0xBC) turned and moved like the body; the height stays the ground's
mtFootXf:
lis r12, mtTurnKeep@ha
addi r12, r12, mtTurnKeep@l
lwz r0, 16(r12)
cmpwi r0, 0
beq mtFootOut
lwz r5, 28(r12)
lis r6, mtHideModel@ha
addi r6, r6, mtHideModel@l
lwz r6, 12(r6)
subf r5, r5, r6
cmplwi r5, 2
bgt mtFootOut
lis r6, mtFx@ha
lwz r0, mtFx@l(r6)
cmpwi r0, 0
beq mtFootOut
lis r6, mtFx@ha
addi r6, r6, mtFx@l
lwz r0, 4(r6)
cmpwi r0, 0
beq mtFootOut
addi r3, r1, 0x188
li r4, 1
bl mtFxXf
addi r3, r1, 0xBC
bl mtFxVec
lis r12, mtFx@ha
addi r12, r12, mtFx@l
lwz r8, 16(r12)
addi r8, r8, 1
stw r8, 16(r12)
mtFootOut:
addi r4, r1, 0x188
b mtFootRet
0x0247BE80 = mtFootRet:
0x0247BE7C = ba mtFootXf

; Rumble. The game's rumble manager starts a pattern on a controller's rumble part by calling
; 0x0238D488 (r3 = the part, r4 = the pattern, r5 = loops) at 0x02496C00, once per rumble event;
; r31 is the pattern's table entry (+0 its priority: 0 strong, 1 medium, 2 weak, 3 very weak,
; 4 pulsed, 5 pulsed weak), r25 the player port. That call comes here: it does what 0x0238D488
; does and records the event in mtRumble for the VR layer, which vibrates the Quest controllers.
mtRumble:
stw r5, 0x1C(r3)
li r0, 0
stw r4, 0x14(r3)
stw r0, 0x18(r3)
lis r12, mtRumbleData@ha
addi r12, r12, mtRumbleData@l
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
stw r25, 12(r12)
lwz r0, 0(r31)
stw r0, 4(r12)
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
mtRumbleDone:
blr
0x02496C00 = bla mtRumble

; Action log (diagnostics, to find the player's clear-pipe action): the game starts an actor's
; action (animation + state name) through 0x023F8F50 (r3 = actor, r4 = the name). Its step at
; 0x023F8F68 (lwz r3,0x30(r30); r30 = actor, r4 = name) comes here: names started on the player
; or its costume actor go into mtActLog's ring (+8, 8 entries, +0 = count); any name starting
; with 'R' (Route...) also goes to +40 with its actor at +44 and a count at +48.
mtActLogHook:
lis r12, mtHideActor@ha
lwz r11, mtHideActor@l(r12)
cmpw r11, r30
beq mtActLogMine
lis r12, mtHideHost@ha
lwz r11, mtHideHost@l(r12)
cmpw r11, r30
bne mtActLogR
mtActLogMine:
; the name is copied (the player's names are built in a buffer that is reused): 24 bytes per entry
lis r12, mtActLog@ha
addi r12, r12, mtActLog@l
stw r30, 4(r12)
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
andi. r11, r11, 7
mulli r11, r11, 24
add r11, r11, r12
addi r11, r11, 8
addi r12, r11, 23
mr r10, r4
mtActLogCopy:
lbz r0, 0(r10)
stb r0, 0(r11)
cmpwi r0, 0
beq mtActLogPipe
addi r10, r10, 1
addi r11, r11, 1
cmplw r11, r12
blt mtActLogCopy
li r0, 0
stb r0, 0(r11)
mtActLogPipe:
; Camera behind Mario for some actions (the 200 camera, as the camera button would), back to first
; person with the player's next other action: inside clear pipes (mtActLog+212: "RouteD..."), and
; in the air (mtActLog+220: actions with "Jump" or "Fall" in the name, or "HipDrop" but not its
; landing) - to see what you jump on.
mflr r9
; Eye height inside clear pipes (mtPipeEye): "RouteDokan" anywhere in the player's action name (Peach's is PeachRouteDokanMove) = inside, any other player action = out
mr r5, r4
lis r6, mtStrRouteDokan@ha
addi r6, r6, mtStrRouteDokan@l
bl mtStrHas
lis r11, mtPipeEye@ha
addi r11, r11, mtPipeEye@l
stw r7, 0(r11)
lis r10, mtEyeFit@ha
addi r10, r10, mtEyeFit@l
lwz r10, 84(r10)
stw r10, 4(r11)
; Captain Toad's stages (the action name contains KinopioBrigade): the eyes sit lower, nearer his red collar, below the helmet lamp (mtPipeEye+16/+20)
mr r5, r4
lis r6, mtStrBrigade@ha
addi r6, r6, mtStrBrigade@l
bl mtStrHas
lis r11, mtPipeEye@ha
addi r11, r11, mtPipeEye@l
stw r7, 16(r11)
; Scene changes and transitions (mtTube+168 = 1): while the player's action is a pipe, door, warp,
; goal, cutscene ("Demo"), death or miss one, the first-person body and gloves are hidden
; (mtFpBody+0 and mtHandCtl+0 kept in mtTube+152/+156, put back with the next other action)
li r7, 0
lis r11, mtTube@ha
addi r11, r11, mtTube@l
lwz r0, 168(r11)
cmpwi r0, 0
beq mtHideDecide
mr r5, r4
lis r6, mtStrDokan@ha
addi r6, r6, mtStrDokan@l
bl mtStrHas
cmpwi r7, 0
bne mtHideWant
lis r6, mtStrDemo@ha
addi r6, r6, mtStrDemo@l
bl mtStrHas
cmpwi r7, 0
bne mtHideWant
lis r6, mtStrDoor@ha
addi r6, r6, mtStrDoor@l
bl mtStrHas
cmpwi r7, 0
bne mtHideWant
lis r6, mtStrGoal@ha
addi r6, r6, mtStrGoal@l
bl mtStrHas
cmpwi r7, 0
bne mtHideWant
lis r6, mtStrWarp@ha
addi r6, r6, mtStrWarp@l
bl mtStrHas
cmpwi r7, 0
bne mtHideWant
lis r6, mtStrDead@ha
addi r6, r6, mtStrDead@l
bl mtStrHas
cmpwi r7, 0
bne mtHideWant
lis r6, mtStrMiss@ha
addi r6, r6, mtStrMiss@l
bl mtStrHas
cmpwi r7, 0
bne mtHideWant
b mtHideDecide
mtHideWant:
li r7, 1
mtHideDecide:
lis r11, mtTube@ha
addi r11, r11, mtTube@l
lwz r0, 160(r11)
cmpwi r7, 0
beq mtHideOff
cmpwi r0, 0
bne mtHideDone
lis r10, mtFpBody@ha
addi r10, r10, mtFpBody@l
lwz r0, 0(r10)
stw r0, 152(r11)
li r0, 0
stw r0, 0(r10)
lis r10, mtHandCtl@ha
addi r10, r10, mtHandCtl@l
lwz r0, 0(r10)
stw r0, 156(r11)
li r0, 0
stw r0, 0(r10)
li r0, 1
stw r0, 160(r11)
b mtHideDone
mtHideOff:
cmpwi r0, 0
beq mtHideDone
lwz r0, 152(r11)
lis r10, mtFpBody@ha
stw r0, mtFpBody@l(r10)
lwz r0, 156(r11)
lis r10, mtHandCtl@ha
stw r0, mtHandCtl@l(r10)
li r0, 0
stw r0, 160(r11)
mtHideDone:
li r7, 0
lis r12, mtActLog@ha
addi r12, r12, mtActLog@l
lwz r8, 224(r12)
li r0, 0
stw r0, 224(r12)
lbz r0, 0(r4)
cmpwi r0, 82
bne mtActLogAir
lbz r0, 1(r4)
cmpwi r0, 111
bne mtActLogAir
lbz r0, 2(r4)
cmpwi r0, 117
bne mtActLogAir
lbz r0, 3(r4)
cmpwi r0, 116
bne mtActLogAir
lbz r0, 4(r4)
cmpwi r0, 101
bne mtActLogAir
lbz r0, 5(r4)
cmpwi r0, 68
bne mtActLogAir
li r0, 1
stw r0, 224(r12)
lwz r0, 212(r12)
cmpwi r0, 0
beq mtActLogWant
li r7, 1
b mtActLogWant
mtActLogAir:
lis r12, mtActLog@ha
addi r12, r12, mtActLog@l
lwz r0, 220(r12)
cmpwi r0, 0
beq mtActLogWant
mr r5, r4
lis r6, mtStrJump@ha
addi r6, r6, mtStrJump@l
bl mtStrHas
cmpwi r7, 0
bne mtActLogWant
lis r6, mtStrFall@ha
addi r6, r6, mtStrFall@l
bl mtStrHas
cmpwi r7, 0
bne mtActLogWant
lis r6, mtStrHipDrop@ha
addi r6, r6, mtStrHipDrop@l
bl mtStrHas
cmpwi r7, 0
beq mtActLogWant
lis r6, mtStrLand@ha
addi r6, r6, mtStrLand@l
bl mtStrHas
xori r7, r7, 1
mtActLogWant:
mtlr r9
lis r12, mtActLog@ha
addi r12, r12, mtActLog@l
cmpwi r7, 0
beq mtActLogNoPipe
lwz r0, 216(r12)
cmpwi r0, 0
bne mtActLogR
lis r11, mtControl@ha
addi r11, r11, mtControl@l
lwz r0, 28(r11)
cmpwi r0, 1
bne mtActLogR
lis r11, mtEyeBack@ha
lwz r0, mtEyeBack@l(r11)
cmpwi r0, 0
bne mtActLogR
lis r10, mtEyeBackCtl@ha
addi r10, r10, mtEyeBackCtl@l
lwz r0, 16(r10)
stw r0, mtEyeBack@l(r11)
li r0, 1
stw r0, 8(r10)
stw r0, 216(r12)
b mtActLogR
mtActLogNoPipe:
lwz r0, 216(r12)
cmpwi r0, 0
beq mtActLogR
li r0, 0
stw r0, 216(r12)
lis r10, mtEyeBackCtl@ha
addi r10, r10, mtEyeBackCtl@l
stw r0, 8(r10)
lwz r0, 12(r10)
lis r11, mtEyeBack@ha
stw r0, mtEyeBack@l(r11)
mtActLogR:
lbz r11, 0(r4)
cmpwi r11, 82
bne mtActLogDone
lis r12, mtActLog@ha
addi r12, r12, mtActLog@l
stw r4, 200(r12)
stw r30, 204(r12)
lwz r11, 208(r12)
addi r11, r11, 1
stw r11, 208(r12)
mtActLogDone:
lwz r3, 0x30(r30)
blr
0x023F8F68 = bla mtActLogHook

; mtStrHas: r7 = 1 when the zero-ended text at r5 contains the one at r6, else 0. Uses r0, r7, r8,
; r10, r11, r12.
mtStrHas:
li r7, 0
mr r8, r5
mtStrHasStart:
mr r10, r8
mr r11, r6
mtStrHasCmp:
lbz r0, 0(r11)
cmpwi r0, 0
beq mtStrHasYes
lbz r12, 0(r10)
cmpw r12, r0
bne mtStrHasNext
addi r10, r10, 1
addi r11, r11, 1
b mtStrHasCmp
mtStrHasNext:
lbz r0, 0(r8)
cmpwi r0, 0
beq mtStrHasRet
addi r8, r8, 1
b mtStrHasStart
mtStrHasYes:
li r7, 1
mtStrHasRet:
blr

; Stick snapping. The player's stick filter (0x022B2558, r4 -> the stick x/y) pulls a stick held
; nearly straight onto the straight line (0x022B1E20 widens that for X, 0x022B212C the general
; snap) unless Mario stands in a 'StickSnapOffArea'. In first person that snap is a dead zone:
; walking where the head looks or the controller points must follow small turns 1:1. So while the
; first-person camera is in use (mtControl+28) and mtStickSnap+0 is 1, the filter returns at once,
; as in a StickSnapOffArea. Its first step (0x022B2570, lwz r3,0x68(r31)) comes here.
0x022B2574 = mtStickSnapRet:
0x022B2700 = mtStickSnapOff:
mtStickSnap:
lis r12, mtStickSnapData@ha
addi r12, r12, mtStickSnapData@l
lwz r11, 0(r12)
cmpwi r11, 0
beq mtStickSnapKeep
lis r11, mtControl@ha
addi r11, r11, mtControl@l
lwz r11, 28(r11)
cmpwi r11, 1
bne mtStickSnapKeep
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
b mtStickSnapOff
mtStickSnapKeep:
lwz r3, 0x68(r31)
b mtStickSnapRet
0x022B2570 = ba mtStickSnap

; Aiming powers with the right controller, like the fireball.
; mtVrGroundDir: in the original first person with the right controller tracked, (f0, f2) = where it
; points on the ground plane (x, z, length 1) and r12 = 1; otherwise r12 = 0. Uses r0, r9..r12 and
; f0..f6 only (r3..r8 are the callers').
mtVrGroundDir:
li r12, 0
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r0, 0(r11)
cmpwi r0, 0
beq mtVrDirNo
lis r9, mtHandW@ha
addi r9, r9, mtHandW@l
lwz r0, 100(r9)
cmpwi r0, 0
beq mtVrDirNo
lis r10, mtEyeBack@ha
lwz r0, mtEyeBack@l(r10)
cmpwi r0, 0
bne mtVrDirNo
lis r10, mtControl@ha
addi r10, r10, mtControl@l
lwz r0, 28(r10)
cmpwi r0, 1
bne mtVrDirNo
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lwz r0, 88(r10)
cmpwi r0, 1
bne mtVrDirNo
lfs f0, 112(r9)
lfs f2, 120(r9)
fmuls f3, f0, f0
fmuls f4, f2, f2
fadds f3, f3, f4
lfs f4, 124(r9)
.int 0xFC032000 ; fcmpu cr0, f3, f4
blt mtVrDirNo
.int 0xFC801834 ; frsqrte f4, f3
fmuls f5, f4, f4
fmuls f5, f5, f3
lfs f6, 128(r9)
fmuls f5, f5, f6
lfs f6, 132(r9)
fsubs f5, f6, f5
fmuls f4, f4, f5
fmuls f5, f4, f4
fmuls f5, f5, f3
lfs f6, 128(r9)
fmuls f5, f5, f6
lfs f6, 132(r9)
fsubs f5, f6, f5
fmuls f4, f4, f5
fmuls f0, f0, f4
fmuls f2, f2, f4
li r12, 1
mtVrDirNo:
blr

; Boomerang (boomerang suit): the throw (0x0229B3F0) sets the boomerang's velocity from the
; player's forward axis times its speed at 0x20(r1) and calls the launch routine at 0x0229B468,
; which takes the flight direction and the start point from that vector. The call comes here: for
; the player's own boomerang ([boomerang+0xE0] = the player) the velocity becomes where the right
; controller points (ground plane) times the same speed. r3/r4/r5 are the launch's arguments.
0x0229AFE0 = mtBoomLaunch:
mtBoomDir:
mflr r8
lis r6, mtPower@ha
lwz r0, mtPower@l(r6)
cmpwi r0, 0
beq mtBoomDirGo
lwz r6, 0xE0(r31)
lis r7, mtHideActor@ha
lwz r7, mtHideActor@l(r7)
cmpw r6, r7
bne mtBoomDirGo
bl mtVrGroundDir
cmpwi r12, 0
beq mtBoomDirGo
lwz r6, 0x84(r31)
lwz r6, 0x10(r6)
lfs f7, 0(r6)
fmuls f0, f0, f7
fmuls f2, f2, f7
stfs f0, 0x20(r1)
li r0, 0
stw r0, 0x24(r1)
stfs f2, 0x28(r1)
lis r6, mtPower@ha
addi r6, r6, mtPower@l
lwz r7, 16(r6)
addi r7, r7, 1
stw r7, 16(r6)
mtBoomDirGo:
mtlr r8
b mtBoomLaunch
0x0229B468 = bla mtBoomDir

; ... and the boomerang starts from the right glove's palm (the launch just wrote its position at r3;
; the game's wall check that follows then works on the palm).
mtBoomPos:
mflr r8
lis r6, mtPower@ha
addi r6, r6, mtPower@l
lwz r0, 4(r6)
cmpwi r0, 0
beq mtBoomPosDone
lwz r6, 0xE0(r31)
lis r7, mtHideActor@ha
lwz r7, mtHideActor@l(r7)
cmpw r6, r7
bne mtBoomPosDone
bl mtVrGroundDir
cmpwi r12, 0
beq mtBoomPosDone
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lfs f0, 76(r11)
lfs f1, 56(r9)
lfs f2, 60(r9)
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 0(r3)
lfs f1, 72(r9)
lfs f2, 76(r9)
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 4(r3)
lfs f1, 88(r9)
lfs f2, 92(r9)
fmuls f1, f1, f0
fadds f1, f1, f2
stfs f1, 8(r3)
mtBoomPosDone:
mtlr r8
mr r3, r30
blr
0x0229B144 = bla mtBoomPos

; Cat dive (cat suit, the "BodyAttack"): its start (0x02250D8C) puts the flattened facing at 8(r1),
; then (0x02250E28) turns Mario to it and sets the dive velocity from it. For the player's own dive
; (the state's pose [[r31+4]] is the player's pose [[player+0xC0]]) the direction becomes where the
; right controller points on the ground plane.
mtCatDive:
mflr r7
lis r6, mtPower@ha
addi r6, r6, mtPower@l
lwz r0, 8(r6)
cmpwi r0, 0
beq mtCatDiveDone
lwz r5, 4(r31)
lwz r5, 0(r5)
lis r4, mtHideActor@ha
lwz r4, mtHideActor@l(r4)
lwz r4, 0xC0(r4)
lwz r4, 0(r4)
cmpw r4, r5
bne mtCatDiveDone
bl mtVrGroundDir
cmpwi r12, 0
beq mtCatDiveDone
stfs f0, 8(r1)
li r0, 0
stw r0, 0xC(r1)
stfs f2, 0x10(r1)
lis r6, mtPower@ha
addi r6, r6, mtPower@l
lwz r5, 20(r6)
addi r5, r5, 1
stw r5, 20(r6)
mtCatDiveDone:
mtlr r7
lwz r8, 4(r31)
blr
0x02250E28 = bla mtCatDive

; Stomp assist (first person). The air states' vertical step (0x0224E6B8) has just written the final
; airborne velocity (r8 = the pose: position at +0, velocity at +0x24; r28 = the calculator, [r28+4]
; its holder = [player+0xC0]; r29 -> the vertical speed, below 0 = falling) when its epilogue
; (0x0224EAD4) comes here. While the local player falls in the original first person, the nearest
; living enemy below him within reach (from the player's 'Eye' sensor contacts, a 200-unit sphere
; the game fills every frame) pulls his horizontal velocity a little toward it: mtStomp+8 of the
; horizontal distance per frame, only inside the radius (mtStomp+4, squared).
mtStompAssist:
lis r12, mtStomp@ha
addi r12, r12, mtStomp@l
lwz r3, 20(r12)
addi r3, r3, 1
stw r3, 20(r12)
lwz r0, 0(r12)
cmpwi r0, 0
beq mtStompDone
; with the camera pulled back (mtEyeBack, the 200 camera) only when mtStomp+68 is 1
lis r11, mtEyeBack@ha
lwz r0, mtEyeBack@l(r11)
cmpwi r0, 0
beq mtStompEyeOk
lwz r0, 68(r12)
cmpwi r0, 0
beq mtStompDone
mtStompEyeOk:
lis r11, mtControl@ha
addi r11, r11, mtControl@l
lwz r0, 28(r11)
cmpwi r0, 1
bne mtStompDone
lfs f0, 0(r29)
fsubs f1, f0, f0
; the block on the last stomped enemy counts down (air frames)
lwz r3, 48(r12)
cmpwi r3, 0
ble mtStompCool
addi r3, r3, -1
stw r3, 48(r12)
mtStompCool:
.int 0xFC000800 ; fcmpu cr0, f0, f1
blt mtStompFalling
; going up right after a pull = the enemy was stomped (the bounce): that enemy is not a target again
; for mtStomp+60 air frames, so the bounce does not come back down onto it for a second jump
lwz r0, 56(r12)
cmpwi r0, 0
beq mtStompDone
li r0, 0
stw r0, 56(r12)
lwz r0, 36(r12)
stw r0, 52(r12)
lwz r0, 60(r12)
stw r0, 48(r12)
b mtStompDone
mtStompFalling:
lwz r3, 24(r12)
addi r3, r3, 1
stw r3, 24(r12)
lis r11, mtHideActor@ha
lwz r11, mtHideActor@l(r11)
lis r0, 0x1000
cmplw r11, r0
blt mtStompDone
lis r0, 0x5000
cmplw r11, r0
bge mtStompDone
andi. r0, r11, 3
bne mtStompDone
; the local player's: r8 is its pose ([[player+0xC0]]), or the calculator's holder is [player+0xC0]
lwz r10, 0xC0(r11)
lwz r9, 4(r28)
cmpw r9, r10
beq mtStompLocal
lis r0, 0x1000
cmplw r10, r0
blt mtStompDone
lis r0, 0x5000
cmplw r10, r0
bge mtStompDone
andi. r0, r10, 3
bne mtStompDone
lwz r10, 0(r10)
cmpw r10, r8
bne mtStompDone
mtStompLocal:
lwz r3, 28(r12)
addi r3, r3, 1
stw r3, 28(r12)
; the player's 'Eye' sensor (its name pointer is 0x103213F4)
lwz r10, 0x4C(r11)
lis r0, 0x1000
cmplw r10, r0
blt mtStompDone
lis r0, 0x5000
cmplw r10, r0
bge mtStompDone
andi. r0, r10, 3
bne mtStompDone
lwz r9, 4(r10)
cmplwi r9, 32
bgt mtStompDone
lwz r10, 8(r10)
lis r0, 0x1000
cmplw r10, r0
blt mtStompDone
lis r0, 0x5000
cmplw r10, r0
bge mtStompDone
andi. r0, r10, 3
bne mtStompDone
lis r7, 0x1032
ori r7, r7, 0x13F4
mtStompFindEye:
cmpwi r9, 0
ble mtStompDone
lwz r6, 0(r10)
addi r10, r10, 4
addi r9, r9, -1
lis r0, 0x1000
cmplw r6, r0
blt mtStompFindEye
lis r0, 0x5000
cmplw r6, r0
bge mtStompFindEye
andi. r0, r6, 3
bne mtStompFindEye
lwz r0, 0(r6)
cmpw r0, r7
bne mtStompFindEye
lbz r0, 0x28(r6)
cmpwi r0, 0
beq mtStompDone
lbz r0, 0x29(r6)
cmpwi r0, 0
beq mtStompDone
lwz r3, 32(r12)
addi r3, r3, 1
stw r3, 32(r12)
lhz r3, 0x1A(r6)
stw r3, 44(r12)
; its contacts: the nearest enemy below, horizontally (f6 = best distance squared, f7/f8 = its dx/dz)
lhz r9, 0x1A(r6)
cmplwi r9, 32
bgt mtStompDone
lwz r10, 0x1C(r6)
lis r0, 0x1000
cmplw r10, r0
blt mtStompDone
lis r0, 0x5000
cmplw r10, r0
bge mtStompDone
andi. r0, r10, 3
bne mtStompDone
lfs f6, 4(r12)
lfs f7, 16(r12)
lfs f8, 16(r12)
li r5, 0
lfs f10, 0(r8)
lfs f11, 4(r8)
lfs f12, 8(r8)
mtStompLoop:
cmpwi r9, 0
ble mtStompPick
lwz r6, 0(r10)
addi r10, r10, 4
addi r9, r9, -1
lis r0, 0x1000
cmplw r6, r0
blt mtStompLoop
lis r0, 0x5000
cmplw r6, r0
bge mtStompLoop
andi. r0, r6, 3
bne mtStompLoop
lwz r0, 4(r6)
cmplwi r0, 31
bgt mtStompNoMask
li r3, 1
.int 0x7C630030 ; slw r3, r3, r0
lwz r4, 64(r12)
or r4, r4, r3
stw r4, 64(r12)
mtStompNoMask:
lwz r0, 4(r6)
cmpwi r0, 5
beq mtStompType
cmpwi r0, 6
beq mtStompType
cmpwi r0, 10
bne mtStompLoop
mtStompType:
lwz r3, 40(r12)
addi r3, r3, 1
stw r3, 40(r12)
lwz r4, 0x2C(r6)
lis r0, 0x1000
cmplw r4, r0
blt mtStompLoop
lis r0, 0x5000
cmplw r4, r0
bge mtStompLoop
andi. r0, r4, 3
bne mtStompLoop
mr r3, r4
lwz r0, 48(r12)
cmpwi r0, 0
ble mtStompFree
lwz r0, 52(r12)
cmpw r0, r3
beq mtStompLoop
mtStompFree:
lwz r4, 0x7C(r4)
lis r0, 0x1000
cmplw r4, r0
blt mtStompLoop
lis r0, 0x5000
cmplw r4, r0
bge mtStompLoop
andi. r0, r4, 3
bne mtStompLoop
lbz r0, 0(r4)
cmpwi r0, 0
bne mtStompLoop
lfs f2, 12(r6)
fsubs f2, f2, f11
lfs f3, 16(r12)
.int 0xFC021800 ; fcmpu cr0, f2, f3
bge mtStompLoop
fmr f13, f2
lfs f2, 8(r6)
fsubs f2, f2, f10
lfs f3, 16(r6)
fsubs f3, f3, f12
fmuls f4, f2, f2
fmuls f5, f3, f3
fadds f4, f4, f5
.int 0xFC043000 ; fcmpu cr0, f4, f6
bge mtStompLoop
fmr f6, f4
fmr f7, f2
fmr f8, f3
fmr f9, f13
mr r7, r3
li r5, 1
b mtStompLoop
mtStompPick:
cmpwi r5, 0
beq mtStompDone
; the horizontal speed that lands on it: (dx, dz) / the frames until landing (the height to fall /
; the vertical speed, at least mtStomp+72); the velocity goes mtStomp+8 of the way there per frame,
; so it homes in without building up speed (no fling)
.int 0xED490024 ; fdivs f10, f9, f0
lfs f3, 72(r12)
.int 0xFC0A1800 ; fcmpu cr0, f10, f3
bge mtStompFrames
fmr f10, f3
mtStompFrames:
.int 0xECE75024 ; fdivs f7, f7, f10
.int 0xED085024 ; fdivs f8, f8, f10
lfs f5, 8(r12)
lfs f2, 0x24(r8)
fsubs f3, f7, f2
fmuls f3, f3, f5
fadds f2, f2, f3
stfs f2, 0x24(r8)
lfs f2, 0x2C(r8)
fsubs f3, f8, f2
fmuls f3, f3, f5
fadds f2, f2, f3
stfs f2, 0x2C(r8)
lwz r4, 12(r12)
addi r4, r4, 1
stw r4, 12(r12)
stw r7, 36(r12)
li r0, 1
stw r0, 56(r12)
mtStompDone:
lmw r27, 0x44(r1)
blr
0x0224EAD4 = bla mtStompAssist

; Picking things up in first person by touch. The player tries a pickup before a kick when one of
; its sensors touches something (0x022892B4, then the kick at 0x0228A7AC); the pickup asks
; "is the grab button (X/Y) held" at 0x02289430 and, if not, gives up so the object gets kicked.
; In the original first person that answer is 'yes' for the touch (the touched sensor is kept in
; mtGrab+0), so touching a shell, a ball or a block picks it up. While it is carried, the same
; question (0x022916D8) keeps saying 'yes' until the grab button has been pressed and let go once
; (a button or the hand-throw gesture, which presses X): then it is thrown, as usual.
mtGrabTouch:
lis r12, mtGrab@ha
addi r12, r12, mtGrab@l
lwz r0, 8(r12)
cmpwi r0, 0
beq mtGrabTouchOrig
lis r11, mtEyeBack@ha
lwz r0, mtEyeBack@l(r11)
cmpwi r0, 0
bne mtGrabTouchOrig
lis r11, mtControl@ha
addi r11, r11, mtControl@l
lwz r0, 28(r11)
cmpwi r0, 1
bne mtGrabTouchOrig
mflr r0
stwu r1, -0x10(r1)
stw r0, 0x14(r1)
bctrl
lwz r0, 0x14(r1)
mtlr r0
addi r1, r1, 0x10
lis r12, mtGrab@ha
addi r12, r12, mtGrab@l
li r0, 0
stw r0, 4(r12)
cmpwi r3, 0
bne mtGrabTouchReal
; r6 = the grips held on tracked controllers (1 left, 2 right)
lis r10, mtPad@ha
addi r10, r10, mtPad@l
li r6, 0
lwz r0, 16(r10)
cmpwi r0, 1
bne mtGripTL
lwz r0, 68(r10)
andi. r0, r0, 32
beq mtGripTL
ori r6, r6, 1
mtGripTL:
lwz r0, 88(r10)
cmpwi r0, 1
bne mtGripTR
lwz r0, 140(r10)
andi. r0, r0, 32
beq mtGripTR
ori r6, r6, 2
mtGripTR:
; mtGrab+28 = 1: only a hand holding its grip picks up (touching alone neither picks up nor kicks)
lwz r0, 28(r12)
cmpwi r0, 0
beq mtGrabGripFree
cmpwi r6, 0
bne mtGrabGripFree
li r3, 0
blr
mtGrabGripFree:
stw r30, 0(r12)
lwz r0, 4(r30)
stw r0, 24(r12)
; the hand holding it (mtGrab+20: 1 right, 0 left): the one gripping; both or none: the nearer glove
li r9, 0
cmpwi r6, 1
beq mtGrabHandSet
li r9, 1
cmpwi r6, 2
beq mtGrabHandSet
li r9, 1
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lwz r0, 16(r10)
cmpwi r0, 1
bne mtGrabHandSet
lis r11, mtHandCtl@ha
addi r11, r11, mtHandCtl@l
lwz r11, 4(r11)
lis r0, 0x1000
cmplw r11, r0
blt mtGrabHandSet
addi r11, r11, 0xB4
lfs f1, 8(r30)
lfs f2, 12(r11)
fsubs f1, f1, f2
fmuls f3, f1, f1
lfs f1, 12(r30)
lfs f2, 28(r11)
fsubs f1, f1, f2
fmuls f1, f1, f1
fadds f3, f3, f1
lfs f1, 16(r30)
lfs f2, 44(r11)
fsubs f1, f1, f2
fmuls f1, f1, f1
fadds f3, f3, f1
li r9, 0
lwz r0, 88(r10)
cmpwi r0, 1
bne mtGrabHandSet
lis r11, mtHandW@ha
addi r11, r11, mtHandW@l
lfs f1, 8(r30)
lfs f2, 60(r11)
fsubs f1, f1, f2
fmuls f5, f1, f1
lfs f1, 12(r30)
lfs f2, 76(r11)
fsubs f1, f1, f2
fmuls f1, f1, f1
fadds f5, f5, f1
lfs f1, 16(r30)
lfs f2, 92(r11)
fsubs f1, f1, f2
fmuls f1, f1, f1
fadds f5, f5, f1
.int 0xFC032800 ; fcmpu cr0, f3, f5
blt mtGrabHandSet
li r9, 1
mtGrabHandSet:
stw r9, 20(r12)
lwz r11, 12(r12)
addi r11, r11, 1
stw r11, 12(r12)
li r3, 1
blr
mtGrabTouchReal:
stw r0, 0(r12)
blr
mtGrabTouchOrig:
bctr
0x02289430 = bla mtGrabTouch

mtGrabHold:
mflr r0
stwu r1, -0x10(r1)
stw r0, 0x14(r1)
bctrl
lwz r0, 0x14(r1)
mtlr r0
addi r1, r1, 0x10
lis r12, mtGrab@ha
addi r12, r12, mtGrab@l
lwz r11, 0(r12)
cmpwi r11, 0
beq mtGrabHoldDone
lwz r10, 0x1C0(r31)
cmpw r10, r11
bne mtGrabHoldClear
; held by grip (mtGrab+28): kept while a grip is held, thrown when the grips are let go - the
; buttons and the throw gesture do not throw it
lwz r0, 28(r12)
cmpwi r0, 0
beq mtGrabHoldButtons
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lwz r0, 68(r10)
lwz r11, 140(r10)
or r0, r0, r11
andi. r0, r0, 32
beq mtGrabHoldThrow
li r3, 1
blr
mtGrabHoldButtons:
cmpwi r3, 0
beq mtGrabHoldUp
li r0, 1
stw r0, 4(r12)
li r3, 1
blr
mtGrabHoldUp:
lwz r0, 4(r12)
cmpwi r0, 0
bne mtGrabHoldThrow
lwz r0, 28(r12)
cmpwi r0, 0
beq mtGrabHoldKeep
lis r10, mtPad@ha
addi r10, r10, mtPad@l
lwz r0, 68(r10)
lwz r11, 140(r10)
or r0, r0, r11
andi. r0, r0, 32
beq mtGrabHoldThrow
mtGrabHoldKeep:
li r3, 1
blr
mtGrabHoldThrow:
li r3, 0
mtGrabHoldClear:
li r0, 0
stw r0, 0(r12)
stw r0, 4(r12)
lwz r11, 32(r12)
cmpwi r11, 0
beq mtGrabHoldDone
lfs f1, 40(r12)
stfs f1, 0(r11)
stfs f1, 4(r11)
stfs f1, 8(r11)
stw r0, 32(r12)
mtGrabHoldDone:
blr
0x022916D8 = bla mtGrabHold

; ... and in the original first person a touch never kicks (the kick message at 0x0228A818 is not
; sent), also when a pickup is refused
0x024098E0 = mtKickSend:
mtKickGate:
lis r12, mtGrab@ha
addi r12, r12, mtGrab@l
lwz r0, 16(r12)
cmpwi r0, 0
beq mtKickGateSend
lis r11, mtEyeBack@ha
lwz r0, mtEyeBack@l(r11)
cmpwi r0, 0
bne mtKickGateSend
lis r11, mtControl@ha
addi r11, r11, mtControl@l
lwz r0, 28(r11)
cmpwi r0, 1
bne mtKickGateSend
; picking up by grip (mtGrab+28): the touch is held back only while a grip is held (you are
; grabbing). This message is how everything touched learns it - a checkpoint flag too - so with
; no grip held it goes out as in the game.
lwz r0, 28(r12)
cmpwi r0, 0
beq mtKickGateHold
lis r11, mtPad@ha
addi r11, r11, mtPad@l
lwz r0, 68(r11)
lwz r12, 140(r11)
or r0, r0, r12
andi. r0, r0, 32
beq mtKickGateSend
mtKickGateHold:
li r3, 0
blr
mtKickGateSend:
b mtKickSend
0x0228A818 = bla mtKickGate

; The game asks its microphone manager three things about a 'sound': is there one right now
; (0x024BC810, a boolean), how loud is it (0x024BC8C4, a float in f1) and is the second sound
; flag set (0x024BC97C, a boolean). While mtMic+4 is 1 they answer for a loud blow, whatever the
; real microphone (Cemu's, if any) hears; otherwise the original code runs unchanged.
mtMicSounding:
lis r12, mtMic@ha
addi r12, r12, mtMic@l
lwz r11, 32(r12)
addi r11, r11, 1
stw r11, 32(r12)
lwz r0, 4(r12)
cmpwi r0, 0
beq mtMicSoundingOrig
lwz r11, 44(r12)
addi r11, r11, 1
stw r11, 44(r12)
li r3, 1
blr
mtMicSoundingOrig:
mflr r0
b mtMicSoundingCont
0x024BC814 = mtMicSoundingCont:
0x024BC810 = ba mtMicSounding
mtMicLevel:
lis r12, mtMic@ha
addi r12, r12, mtMic@l
lwz r11, 36(r12)
addi r11, r11, 1
stw r11, 36(r12)
lwz r0, 4(r12)
cmpwi r0, 0
beq mtMicLevelOrig
lwz r11, 44(r12)
addi r11, r11, 1
stw r11, 44(r12)
lfs f1, 8(r12)
blr
mtMicLevelOrig:
mflr r0
b mtMicLevelCont
0x024BC8C8 = mtMicLevelCont:
0x024BC8C4 = ba mtMicLevel
mtMicFlag2:
lis r12, mtMic@ha
addi r12, r12, mtMic@l
lwz r11, 40(r12)
addi r11, r11, 1
stw r11, 40(r12)
lwz r0, 4(r12)
cmpwi r0, 0
beq mtMicFlag2Orig
lwz r11, 44(r12)
addi r11, r11, 1
stw r11, 44(r12)
li r3, 1
blr
mtMicFlag2Orig:
mflr r0
b mtMicFlag2Cont
0x024BC980 = mtMicFlag2Cont:
0x024BC97C = ba mtMicFlag2




; mtFireStat: counters for the launcher's summary (nothing reads them in the game). Words, by offset:
; 0 'MFST', 4 game frames (pad reads), 8 fireball set-ups, 12 of them with the start at the glove,
; 16 why the last one did not (1 hands switch off, 2 switch word 104 = 0, 3 right glove never drawn,
; 4 camera behind Mario, 5 not first person, 6 right controller lost), 20 set-ups seen by the
; direction hook, 24 with the direction of the hand, 28 why the last one did not (the same numbers,
; 7 = hand pointing straight up or down), 32 frame of the right glove's last update, 36 how many
; frames old it was at the last fireball, 40 the oldest so far, 44 frame X last went down, 48 frames
; from that to the last fireball, 52 the longest so far, 56 fireballs started at the glove, 60/64/68
; the last start (game units), 72/76/80 the last direction, 84 X was down at the last pad read.
mtFireStat:
.int 0x4D465354
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0

; mtHandPick: the previous parts model's actor, model and joint matrix while the child list is walked,
; and a flag that the current child completed the (left, right) pair.
mtHandPick:
.int 0
.int 0
.int 0
.int 0

mtHideModel:
.int 0 ; runtime model pointer
.int 0 ; most recent validated camera scene epoch
.int 0 ; suppressed shape-query count (private diagnostics)
.int 0 ; scene calculation epoch
.int 0 ; captured model count
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
mtHideActor:
.int 0
; Player body in first person, used while the camera sits behind the head
; (mtEyeBack above 0; at 0 the whole body is hidden, the original behaviour).
; Each bit keeps one of the player's shapes hidden (bit 0 = first shape
; captured, up to 17). 0 = the whole body is drawn; 0xFFFFFFFF = all hidden.
mtHideMask:
.int 0
; mtPunch: the punch. +0 on (1), +4 the squared hand speed (tracking units per step) that arms it (2025 = 45 per step), +8 how far (game units) the
; glove's reach goes beyond an enemy sensor's radius (45), +12 steps of rest after a hit (20), +16/+20 the lowest/highest sensor type it hits (5..10),
; +24 what is sent: 0 the spin attack (the game's own message for Mario's spin), 1 the body attack, 2 a fireball hit, 3 the stomp message;
; +28 the sensor director (caught), +32 the sensor pool (caught), +36/+40 the rest left for the left/right hand, +44 sensors created seen;
; counters +48 glove updates, +52 armed (grip + speed), +56 sensors looked at, +60 in reach, +64 messages sent, +68 accepted, +72 refused;
; +76 the last target sensor, +80 its type, +84 its owner, +88 the sender sensor used; +92 how far ahead of the glove's middle the fist is (10),
; +96 the latest squared speed with the grip held, +100 the biggest one so far, +104 a huge float, +108 no director yet, +112 no sender sensor,
; +116 no player yet, +120 pool of the last sensor created
mtPunch:
.int 1
.int 0x44FD2000
.int 0x42340000
.int 20
.int 5
.int 10
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x41200000
.int 0
.int 0
.int 0x7149F2CA
.int 0
.int 0
.int 0
.int 0
; the message log: +0 'MMSG', +4 entries, +8 messages in all, +16.. entries of 16 bytes (message vtable, receiver sensor type, sender sensor type, count)
mtMsgLog:
.int 0x4D4D5347
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; The in-headset options menu (B + Y, drawn by cemuvr_layer.dll) finds its settings through this
; table: magic 'MVRM', version, count, then the guest address of each settings block, in this order.
mtMenuTable:
.int 0x4D56524D
.int 1
.int 24
.int mtFpBody
.int mtEyeFit
.int mrSnapSin
.int mrSnapCos
.int mtFpBackMax
.int mtEyeBackCtl
.int mtHandCtl
.int mtEyeBack
.int mtControl
.int mtCine
.int mtRumbleData
.int mtGlovePoses
.int mtStomp
.int mtThrow
.int mtLevel
.int mtGrab
.int mtActLog
.int mtTube
.int rrCameraOriginal
.int mtPunch
.int mtPipeEye
.int mrSceneClass
.int mtBodyFollow
.int mrLookCos
; Player body in the original first person (camera distance 0): each bit draws one shape of the
; player's own body model (bit 0 = first shape; Mario has 5, Peach 6), so looking down shows the
; body; 0 = hidden as in the original. The eyes, face and other parts stay hidden, the gloves
; follow the controllers. Second word: the body is drawn only while the right-stick pull-back
; (mtFpBack) is at most this many game units (float; 600 = 0x44160000 = always, the body follows the
; pulled-back view; 10 = 0x41200000 hides it once pulled back). Eighth word: how far the view
; sits ahead of the body (float, game units; + moves the body back, - forward; 0 = under the eyes).
; Third word: 1 = the head (cap, hair, face) is removed from the body so only the body is seen,
; 0 = the head is drawn with it. Fourth word: 1 = the body turns with the view (right stick turning),
; 0 = it faces the way the game has it. Fifth word: 1 = each arm (sleeve) reaches from the shoulder
; to its VR glove (shrinks away when that controller is not tracked); 0 = the game's arms are drawn. Sixth word: how wide the removed head's flat lid over the
; collar is (float, 0 = the head shrinks to a point, now; 0.35 = 0x3EB33333 a flat lid). Seventh word:
; 1 = the body stands under the view (follows the stick pull-back and stepping in the room), needs
; the fourth word; 0 = it stays where the game has Mario.
mtFpBody:
.int 0xFFFFFFFF
.int 0x44160000
.int 1
.int 1
.int 1
.int 0
.int 1
.int 0
; the six arm bones' world matrices while mtHeadWrap has them changed
mtArmSave:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtHeadWrap's arm scratch (vectors, lengths) and constants 1.0, 0.05, 4.0 (the most an arm stretches)
; shadow hooks: magic 'MSHD', player-category masks while turned, of them the player's own, and
; the last matched mask's position (x, y, z)
; mtThrow: 0 switch, throw direction follows the right controller (1 = on, 0 = the game's facing),
; 4 switch, the carried object sits in the right glove (1 = on, 0 = between Mario's hands); runtime:
; 12/16/20 the facing vector while replaced, 24 replaced flag, 28 the pose it belongs to; counters:
; 32 throws by anyone, 36 throws aimed with the hand, 40 carried-object placements in the glove.
mtThrow:
.int 1
.int 1
.int 0x41200000 ; +8 the carried object sits this many glove units past the palm (float, 10)
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 1 ; +44 1 = thrown straight where the head faces, 2 = where the holding hand points, 0 = where the right controller points
.int 1 ; +48 1 = follows the hand's reach (mtCarryReach), 2 = in front of the body (the view), 0 = along the glove's fingers
.int 0x41A00000 ; +52 how far ahead of the wrist (float, 20 units; menu: 0 .. 40)
.int 0x41700000 ; +56 how far below the hand (float, 15 units; menu: 31 .. -1)
.int 0x3F000000 ; +60 0.5
.int 0x41F00000 ; +64 how far outward from the hand (float, 30 units)
.int 0x3BE1FC78 ; +68 1/145 (the offsets are for Mario's eye height, 145)
.int 0x3ECCCCCD ; +72 0.4, the smallest size factor
.int 0x3FCCCCCD ; +76 1.6, the largest
.int 0x41200000 ; +80 held with both hands: below the hands (float, 10 units)
.int 0x41700000 ; +84 held with both hands: ahead of the hands (float, 15 units)
.int 0x42C80000 ; +88 throw toward the hand: the hand at least 10 units from the head (squared, 100)
.int 0 ; +92 where the carried object's place was last written (diagnostics)
.int 0 ; +96 1 = while holding something by grip and standing, Mario faces where the head looks (off: standing then holds it like walking)
.int 0x3D23D70A ; +100 standing = the left stick below 0.2 (squared, 0.04)
.int 0x42700000 ; +104 in front of the body: added to the distance (+52) (float, 60)
.int 0x42200000 ; +108 in front of the body: added to the height below (+56) (float, 40)
.int 0x3FCCCCCD ; +112 how much the hand's reach is stretched on the level (1.6)
.int 0 ; +116 the last place written (x, y, z; diagnostics)
.int 0
.int 0
; mtFx: 0 switch (1 = the player's effects go with the body drawn under the view, 0 = where the
; game has them), 4 footprints too (1 / 0); counters: 8 emitters moved at creation, 12 follow
; updates moved, 16 footprints moved.
mtFx:
.int 1
.int 1
.int 0
.int 0
.int 0
; mtRumbleData: 0 how many rumble events player 1's controller got (the VR layer vibrates on each
; new one), 4 the last one's priority (0 strong .. 5 pulsed weak).
; mtPower: switches (1 on / 0 off) 0 the boomerang flies where the right controller points, 4 it
; starts from the right glove, 8 the cat dive goes where the right controller points; counters 16
; boomerangs aimed, 20 cat dives aimed.
mtPower:
.int 1
.int 1
.int 1
.int 0
.int 0
.int 0
; mtGlovePoses: the glove mesh shown while the grip is held (0 = tight fist), while only the trigger is
; held (1 = half-closed; 4 = flat, 3 = open...), and the switch (1 on, 0 = always the game's pose).
mtGlovePoses:
.int 0
.int 1
.int 1
.int 0 ; +12 shape queries answered with a forced pose (diagnostics)
.int 3 ; +16 the mesh while nothing is held (3 = open hand; -1 = the game's own pose)
; (mtRumbleData +8 rumble starts for any port, +12 the last one's port: diagnostics)
; mtShLook: the player's shadow in first person: size factor (1.3), colour factor (0.6: darker), then
; the colour handed on (runtime, 4 floats).
mtShLook:
.int 0x3FA66666
.int 0x3F19999A
.int 0
.int 0
.int 0
.int 0
; mtGrab: 0 the sensor picked up by touch (runtime), 4 the grab button was pressed while holding it
; (runtime), 8 switch: pick up by touch in first person (1 / 0), 12 pickups by touch (counter),
; 16 switch: no kicking by touch in first person (1 / 0), 20 the hand that touched it (1 right,
; 0 left: it is held in that hand and only that hand's throw gesture throws it), 24 the touched
; sensor's type (diagnostics).
mtGrab:
.int 0
.int 0
.int 1
.int 0
.int 1
mtGrabHand:
.int 1
.int 0
.int 1 ; +28 1 = picking up needs a grip held, and letting go of all grips throws; 0 = touch alone
.int 0 ; +32 the held object's scale vector while it is drawn smaller (runtime)
.int 0x3F800000 ; +36 its size in the hand (float, 1 = as the game has it)
.int 0x3F800000 ; +40 1.0
; mtStomp: stomp assist in first person: 0 switch (1 / 0), 4 reach (horizontal distance squared,
; 14400 = 120 units), 8 how much of the horizontal distance to the enemy is added to the velocity
; per frame while falling (float, 0.2 of the way to the landing speed), 12 frames it pulled (counter).
mtStomp:
.int 1
.int 0x46610000
.int 0x3E4CCCCD
.int 0
.int 0 ; +16 0.0
; diagnostics: +20 calls, +24 falling in first person, +28 the local player's, +32 its Eye sensor
; found, +36 the enemy last pulled toward (its owner), +40 enemy contacts seen, +44 the last contact
; count; +48 air frames the block lasts still, +52 the blocked enemy, +56 1 = pulled since the last
; rise, +60 how long a stomped enemy stays blocked (air frames, 90), +64 the sensor types seen in the
; contacts while falling (bit mask, diagnostics), +68 1 = also with the camera pulled back behind
; the head (the 200 camera), 0 = only in the original first person
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 90
.int 0
.int 1
.int 0x41000000 ; +72 the fewest frames to landing the speed is worked out for (8.0: caps the speed)
; mtStickSnapData: 0 switch (1 = no stick snapping while the first-person camera is in use),
; 4 filter calls skipped (counter).
mtStickSnapData:
.int 1
.int 0
; mtLevel: 0 switch (1 = map, title and cutscene cameras kept level: decoupled pitch), 4 counter,
; 8 the smallest horizontal part (squared) of the view direction that is levelled, 12 0.5, 16 1.5,
; 20 0.0, 24 1.0, 28 spare, 32.. the level camera (22 words)
mtLevel:
.int 1
.int 0
.int 0x3B23D70A
.int 0x3F000000
.int 0x3FC00000
.int 0x00000000
.int 0x3F800000
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtActLog: 0 player actions counted, 4 the actor of the last, 8.. ring of 8 names (24 bytes each,
; copied), 200 the last 'R...' action name (pointer), 204 its actor, 208 their count; 212 switch:
; 1 = the camera goes behind Mario inside clear pipes; 216 1 = it was put there (runtime); 220 1 = also
; while jumping / falling; 224 1 = the player is inside a clear pipe (runtime); 228.. what the game got
; from the pad (left x, y, right x, y, buttons) and the camera mode / first-person flag (diagnostics)
mtActLog:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 1
.int 0
.int 1
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtTube: 0 switch (1 = in clear pipes the first-person view turns to the travel direction; off by
; default, the user did not like it), 4 frame
; seen, 8 previous player position, 20 travel direction (unit), 32 previous valid, 36 direction valid,
; 40 easing per frame, 44 the least movement per frame (squared) that turns the view, 48 0.5, 52 the
; turned camera is in use this frame (runtime), 56 1.5, 60 the least level part (squared) of the
; direction before the camera's own right is used, 64.. the turned camera (22 words)
mtTube:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x3E19999A
.int 0x3E800000
.int 0x3F000000
.int 0
.int 0x3FC00000
.int 0x3C23D70A
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0 ; +152 mtFpBody+0 kept while hidden in a clear pipe
.int 0 ; +156 mtHandCtl+0 kept
.int 0 ; +160 1 = they are hidden now
.int 0 ; +164 spare
.int 1 ; +168 1 = hidden during pipes, doors, warps, goals, cutscenes, deaths
mtStrDokan:
.int 0x446F6B61
.int 0x6E000000
.int 0x00000000
; mtPipeEye: 0 1 = the player is in a clear pipe ride (runtime), 4 the eye height to use there (copied from mtEyeFit+84, 60, at the start of the ride), 8 the height in use (runtime, eased; 0 = not started),
; 12 easing per step (0.2)
mtPipeEye:
.int 0
.int 0
.int 0
.int 0x3E4CCCCD
.int 0 ; +16 1 = the player's action is Captain Toad's (KinopioBrigade; runtime)
.int 0xC2340000 ; +20 how much lower the eyes are in his stages (float, game units, -45; 0 = as everywhere; the menu sets it)
.int 0 ; +24 the Bill Box suit is worn: a countdown (runtime; 3 when a BoxKiller model is seen around the eye, counted down by rrCameraHook)
.int 0x42200000 ; +28 how much higher the eyes are with the suit (float, game units, 40; the menu sets it)
.int 1 ; +32 the body follows the player's real turning and the character turns with it (1 = yes; the menu "Corpo acompanha o giro real" sets it; on by default since Version 1.9)
.int 0 ; +36 mtSnapMask: a snap turn has just happened (bit mask shifted right per eye step; runtime)
; mtBodyFollow: the body's heading (x, z) in the tracking space, written by the layer every frame while the option is on (0, -1 = the tracking forward)
mtBodyFollow:
.int 0
.int 0xBF800000
mtStrRouteDokan:
.int 0x526F7574
.int 0x65446F6B
.int 0x616E0000
.int 0x00000000
mtStrBrigade:
.int 0x4B696E6F
.int 0x70696F42
.int 0x72696761
.int 0x64650000
.int 0x00000000
mtStrDemo:
.int 0x44656D6F
.int 0x00000000
mtStrDoor:
.int 0x446F6F72
.int 0x00000000
mtStrGoal:
.int 0x476F616C
.int 0x00000000
mtStrWarp:
.int 0x57617270
.int 0x00000000
mtStrDead:
.int 0x44656164
.int 0x00000000
mtStrMiss:
.int 0x4D697373
.int 0x00000000
; mtMapYaw: 0 switch (1 = the world map view turns freely with the right stick), 4 1 = the turned copy is
; in use (runtime), 8 turn per pad
; read at full tilt (radians), 12 dead zone, 16/20 cos/sin of the turn (runtime), 24 0.5, 28 1.0,
; 32 1.5, 36.. the turned camera (22 words)
mtMapYaw:
.int 1
.int 0
.int 0x3CA3D70A
.int 0x3E4CCCCD
.int 0x3F800000
.int 0
.int 0x3F000000
.int 0x3F800000
.int 0x3FC00000
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
mtStrJump:
.int 0x4A756D70
.int 0
mtStrFall:
.int 0x46616C6C
.int 0
mtStrHipDrop:
.int 0x48697044
.int 0x726F7000
mtStrLand:
.int 0x4C616E64
.int 0
mtRumbleData:
.int 0
.int 0
.int 0
.int 0
mtShStat:
.int 0x4D534844
.int 0
.int 0
.int 0
.int 0
.int 0
; the player's costume actor (host of its shadow masks), kept by the capture
mtHideHost:
.int 0
; the shadow matrix handed on in place of the mask's own
mtShScratch:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; the body's last turn (cos, sin, axis x, axis z, valid, new spot x, z, scene tick) for the parts
; hanging from it and the shadow
mtTurnKeep:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; a part's skeleton while turned: matrix array, bone count, rows 0 and 2 of up to 16 bones
mtPartSave:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; first-person eye height from the character's neck: factor (145 / Mario's 99.5), easing per step,
; lowest, highest, on (1) / off (0 = Mario's 145, +24), then +20 a fine adjustment added to either
mtEyeFit:
.int 0x3FBA885D
.int 0x3D4CCCCD
.int 0x42480000
.int 0x453B8000
.int 0
.int 0x40A00000 ; +20 fine adjustment for a big character, game units (float, +5; the menu sets it)
.int 0x43110000 ; +24 the height when off (145)
.int 0 ; +28 highest neck height seen (runtime)
.int 0 ; +32 its skeleton (runtime)
.int 0x3C23D70A ; +36 how much that height is lowered per step (0.01 units)
.int 0x3F800000 ; +40 1.0 (constants for the model scale)
.int 0x3F000000 ; +44 0.5
.int 0x358637BD ; +48 1e-6
.int 0x3FC00000 ; +52 1.5
.int 0x3F800000 ; +56 the body model's scale last measured (runtime; the gloves grow with it)
.int 0x42DC0000 ; +60 below this eye height the character counts as small (float, 110)
.int 0x41C80000 ; +64 fine adjustment for a small character (float, +25)
.int 0 ; +68 the first-person camera this far ahead of Mario's eyes (float, game units; - = behind)
.int 0 ; +72 how much higher than Mario's eye height (+24) a tall character may see from in the "Sempre a do Mario" mode (float, game units; 0 = Mario's)
.int 0x3E000000 ; +76 how much smaller (share) the gloves are when the body is giant (0.125)
.int 0x3F800000 ; +80 1 / (the body scale - 1 at which that reduction is complete): 1.0 = complete at twice the normal size
.int 0x42700000 ; +84 eye height inside clear pipes (float, game units above the player's origin; 60 = the user's choice, for every character; 0 = off, the standing height as before)
; mtArmHold: per arm (left at +0, right at +160): 36 words = the arm's bones 15,16,17 / 19,20,21 as last built, +144 valid, +148 consecutive failures held,
; +152 failures held in all, +156 the most failures held in a row (8)
mtArmHold:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 8
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 8
; mtArmLog: +0 entries written, then 128 entries of 16 words (see the note at the top of patch_armlog.py)
mtArmLog:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
mtArmTmp:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x3F800000
.int 0x3D4CCCCD
.int 0x40800000
.int 0x3F800000 ; +172 arm thickness factor of the small characters (1.0 normally; the glove size code sets it)
.int 0x41600000 ; +176 mtArmEndD: the arm's end goes this many units per 1.0 of extra thickness on into the glove (14; was 20 with a pointed end)
.int 0x3F800000 ; +180 mtArmTaper: the forearm's thickness relative to the upper arm's (1.0 normally; the glove size code sets it, mtGloveSize+76)
.int 0 ; +184 mtArmCapHits: how many times an arm hit its stretch cap (+168) and ended short of the glove
.int 0 ; +188 mtArmStale: arm blocks where the part's copy of the glove position (+0xB4) is more than 0.1 units from mtHandW
.int 0 ; +192 arm blocks seen
.int 0x3F800000 ; +196 mtArmLead: on a frame with a game step the arm's glove position is moved on by this many steps of the glove's movement (1.0; 0 = off)
.int 0x45610000 ; +200 the squared movement (game units) above which the lead is not applied (3600 = 60 units)
.int 0x40800000 ; +204 mtArmBend: the arm is built toward the point this far (game units) behind the glove's origin along its finger axis; the bend of the wrist takes place over it
.int 0 ; +208 the glove's place (x), after the lead
.int 0 ; +212 y
.int 0 ; +216 z
.int 0 ; +220 the glove's finger axis (unit; 0 = no bend) x
.int 0 ; +224 y
.int 0 ; +228 z
.int 1 ; +232 1 = the wrist bends with the hand, 0 = the old straight end
; mtHeadWrap's work area: 0 the Head bone's 3x3 while zeroed, 36 the world matrix array, 40/44 turned /
; head zeroed flags, 48 constants, 64 the saved rows
mtHeadSave:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x358637BD ; 1e-6
.int 0x3F000000 ; 0.5
.int 0x3FC00000 ; 1.5
.int 0
; rows 0 and 2 of the 22 bones' world matrices while they are turned
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; First person: how far the camera sits behind the head, in game units (float).
; It is moved along the view's own backward axis, so it follows where you look.
; 0 = the camera is at the eyes and the body is hidden: the original first
; person. Mario's eye height is 145 units.
;   0.0 = 0x00000000   40 = 0x42200000   80 = 0x42A00000   120 = 0x42F00000
;   160 = 0x43200000   200 = 0x43480000
mtEyeBack:
.int 0
; Camera behind Mario: 1 = ignore how far the head has drifted from the recentre
; point, so the camera stays centred on Mario (each eye keeps its own offset, so
; stereo is unchanged); 0 = the head's position moves the camera as before.
mtEyeBackLock:
.int 1
; Camera distances. The camera switch button (R3 / right stick click) walks
; through the first two values below in first person - the first is where first
; person starts, and 0 there means the original first person, the second is 200 -
; and the press after the second returns to diorama.
; Words: extra button mask (0 = off; 4 = Minus, the left VR controller's stick
; click, would step the distance on its own), previous state, current step,
; then the distances as floats (the third is not used; it stays at 200). The step has to be 0 at start and
; mtEyeBack has to start equal to the first value.
;   40 = 0x42200000   60 = 0x42700000   80 = 0x42A00000   120 = 0x42F00000
;   160 = 0x43200000  200 = 0x43480000  260 = 0x43820000
; First person pull-back: mtFpBackMax the most the right stick can move the view back in the original
; first person (float, game units; 150 = about 1 m, 0 switches it off), mtFpBack the current amount
; (runtime, put back by the launcher from fp-distance.txt).
mtFpBackMax:
.int 0x00000000
mtFpBack:
.int 0x00000000 ; @FP_DIST
mtEyeBackCtl:
.int 0
.int 0
.int 0
.int 0
.int 0x43480000 ; @CAM_DIST
.int 0x43480000

; Hands in the original first person. The controllers move Mario's own glove models.
; mtHandCtl: 0 master switch (1 = on), 44 how far the gloves sit forward along the way the
; controller points (game units, float; 150 units = 1 m, so 20 = about 13 cm), 48 how many game frames
; ahead the gloves are predicted (float, 0 = no prediction), 52 the hand movement per frame, squared,
; above which the prediction is dropped (a tracking jump), 56 the size of the gloves as a factor (float)
; for Mario, Luigi and Toad, 60 the same for Peach and Rosalina, 64 which of the two is in use (runtime),
; 4/8 the left/right glove actors and 36/40 their
; models (captured every frame), 16/20 orientation preset per hand (0..23) for Mario, Luigi and Toad and
; 68/72 the same for Peach and Rosalina (the set in use follows the flag at 64); cycled by holding grip L +
; Minus for the left glove and grip R + Minus for the right for as many game frames in a row as offset 80
; says (default 20, about a third of a second at 60 reads a second) - not a tap, so the grip and the stick
; click a hand also uses to move and to grip cannot step it by a one-frame coincidence during ordinary play;
; the launcher puts back what was calibrated last time (hand-presets.txt, through the @HP_ markers), 24/28
; how many frames the chord has been held (or -1 once it has already stepped the preset for this hold, so
; holding past that does not keep stepping; both reset to 0 when the chord is let go). Default 11 (left)
; and 8 (right): both gloves with the fingers forward, the thumb up and the palm turned inward - worked out
; from the glove models (fingers along +Z, thumb along -X on the left glove and +X on the right one, palm
; toward -Y), 32 = 1 keeps those two button chords active. Set 0 to switch the hands off. 76 where the fireball
; leaves the right glove: its distance from the wrist along the fingers, in glove units (float, 13 =
; the middle of the palm of Mario's and Peach's gloves; 0 = the wrist).
mtHandCtl:
.int 1
.int 0
.int 0
.int 0
.int 11 ; @HP_ML
.int 8 ; @HP_MR
.int 0
.int 0
.int 1
.int 0
.int 0
.int 0x41200000
.int 0x3FC00000
.int 0x471C4000
.int 0x3F333333
.int 0x3FA66666
.int 0
.int 2 ; @HP_PL
.int 2 ; @HP_PR
.int 0x41500000
.int 20
; mtGloveSize: glove size and arm thickness of the characters with small hands, floats. The hand models differ a lot
; (measured from the game files, mean diagonal of the 7 poses: Mario 50.0, small Mario 45.0, Peach 25.5, Rosalina 24.4,
; Toad 23.4, small Peach 19.6, small Rosalina 18.3, small Toad 17.3), but mtHandCtl+56 / +60 only know two classes and
; Toad shared Mario's, so his gloves were drawn at about half of Mario's size. The glove model is told by its vertex total
; (Peach 2563/2586, small Peach 3032/3101, Rosalina 2538/2496, small Rosalina 2523/2431, Toad and small Toad 3381/3462; the
; cat claws, Mario and small Mario, Toad's raccoon hands have 4800 and more and keep the old sizes), grown-up or small form
; by the upper-arm length the arm code measures (mtArmTmp+120: Peach and Rosalina 25.5, their small forms 14.0, Toad 9.4,
; small Toad 5.6). The size is also multiplied by the menu's glove size (mtHandCtl+56 / 0.7).
; Sizes (the first try, Toad 1.5 = Mario's absolute size, was "gigante" in the headset): +0 Peach/Rosalina (0.95), +4 their
; small forms (1.3), +16 Toad (1.2), +24 small Toad (1.6). Thresholds on the upper-arm length: +8 below it the arm has not
; been measured yet (4.0), +12 above it Peach/Rosalina are grown-up (20.0), +20 above it Toad is grown-up (8.0).
; +28 1.0, +32 1/0.7. Arm thickness (the arm's cross-section is multiplied by it, mtArmTmp+172): +36 Peach/Rosalina (1.2),
; +40 their small forms (1.3), +44 Toad (1.35), +48 small Toad (1.55). The thickness follows the glove's wrist: Mario's sleeve (radius 8.2)
; is 1.4 times his glove's cuff (5.9), and the same ratio is kept for the others.
mtGloveSize:
.int 0x3F99999A
.int 0x3FA66666
.int 0x40800000
.int 0x41A00000
.int 0x3F99999A
.int 0x41000000
.int 0x3FCCCCCD
.int 0x3F800000
.int 0x3FB6DB6E
.int 0x3FC00000
.int 0x3FA66666
.int 0x3FACCCCD
.int 0x3FC66666
.int 0x41566666
.int 0x41300000
.int 0x40F00000
.int 0x41166666
.int 0x40D33333
.int 0x3F800000
.int 0x3F4CCCCD
.int 0x41200000
.int 0
; +76 the forearm's thickness relative to the upper arm's for Toad (0.8; the other characters 1.0); +80 / +84 how far the arm's end
.int 0x40800000
.int 0x41000000
.int 0x41500000
.int 0x40B00000
.int 0x3F8CCCCD
; +104 the default arm thickness per unit of glove size (mtGlvThick: 1.1, the Galaxy rule: thickness = glove scale x 1.1, at most 1.0)
; +88..+100 the most the arm is stretched toward the glove, times its own length (mtArmCap): 4.0 normally, +92 Toad 8.0, +96 small Toad 13.0,
; +100 small Peach / Rosalina 5.5 (their arm chains are short; the reach stays about 1 m)
; goes into the glove per 1.0 of extra thickness (mtArmFlush: 14.0 normally, 0.0 for the Toad family: the end is flush with the wrist)
; +52..+68 where the middle of the glove lies along its fingers, in glove units, measured from the glove models (vertex centroid, mean
; of the 7 poses): +52 Mario, Luigi, the cat claws and everything else (13.4), +56 Peach and Rosalina (11.0), +60 their small forms (7.5),
; +64 Toad (9.4), +68 small Toad (6.6); +72 how much of that the glove is moved back (1.0 = the middle of the hand on the controller's point).
; mtHandShift: per hand (left 0..11, right 12..23) the world vector the wrist was moved by; the carried object takes it back off the wrist.
mtHandShift:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtGlDbg: +0 / +12 the previous step's glove position (left / right), +24 / +28 skeleton roots seen at this step's left glove / the previous step's,
; +32 / +36 the same for the right glove, +40 skeleton steps seen, +44 diagnostic on (1), +48 the squared distance (game units) that counts as a
; match, +52 / +56 times the left / right glove skeleton was drawn with mtHandW (mtGlFix), +60 mtGlFix on (1)
mtGlDbg:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 1
.int 0x3C23D70A
.int 0
.int 0
.int 1
; mtGlRing: +64 the next index, +68.. the last 64 events (bytes): 0x10+h glove h updated, 0x20+h arm block h ran, 0x30+h a skeleton root at glove h
mtGlRing:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtHandCam: 0 the 3x3 turning tracking space into the game world, 36 and 48 each
; eye's world position, 60 and 64 their valid flags, 68 a 3x3 scratch (32 words).
mtHandCam:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtHandOff: the 24 orientation presets, 3x3 each.
mtHandOff:
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x3F800000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0xBF800000
.int 0x00000000
.int 0x00000000

; Attack gesture (the right controller here; the left one has the same, see mtSwingL). The right hand's position relative to the head is watched
; once per pad read. Mode 2 (a fishing cast): the hand first moves toward the head fast enough
; (wind-up, remembered for a short time), then away from it fast enough (the cast), and that
; presses the game's X - the run/attack button, the same one the right controller's B sends -
; for a few reads: fireball, cat scratch. (The game's own B is a second jump button.) Sideways or
; up-down moves at arm's length count for nothing, and the left controller is ignored.
; mtSwing: 0 mode (0 off, 1 any fast move of the right hand, 2 the cast), 4 the speed squared
; that mode 1 needs, 8 reads X is held, 12 reads before the next attack can fire, 16/20 their
; running counters, 24 previous-sample flag, 32/36/40 the previous hand-head vector, 44 speed
; squared toward the head that counts as the wind-up (64 = 8 units), 48 speed squared away from the head that
; counts as the cast, 52 the smallest hand-head distance squared that is looked at, 56 how many
; reads the wind-up stays valid, 60 its counter, 64 fired-this-read flag, 68 wound-up flag.
; Speeds are in controller-position units per pad read (about 1500 units = 1 m; the pad is read once
; per game frame, 60 or 120 times a second by preset: 20 units = 0.8 to 1.6 m/s). Floats: 4, 44, 48, 52.
mtSwing:
.int 2
.int 0x44FD2000
.int 4
.int 24
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x42800000
.int 0x43C80000
.int 0x46AFC800
.int 45
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtSwingL: the attack gesture for the left controller, same layout as mtSwing (0 = mode, 2 = the
; cast; 0 = off).
mtSwingL:
.int 2
.int 0x44FD2000
.int 4
.int 24
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x42800000
.int 0x43C80000
.int 0x46AFC800
.int 45
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
; mtRunGate (hook 0x0236AC84, the game's pad update: stw r11, 0(r29) = the buttons that went down on this read): while the right B alone holds X (mtRunB+4) the X press (8)
; is taken out, so the Mario runs (X is still held) but no fireball is thrown and the cat does not scratch; mtRunB+8 puts an X press in for one read (the attack gesture, also while
; B is held). r11 = pressed word, r29 = the pad object; r12 and r0 are free here.
mtRunGate:
lis r12, mtRunB@ha
addi r12, r12, mtRunB@l
lwz r0, 4(r12)
cmpwi r0, 0
beq mtRunGatePulse
rlwinm r11, r11, 0, 29, 27
mtRunGatePulse:
lwz r0, 8(r12)
cmpwi r0, 0
beq mtRunGateDone
ori r11, r11, 8
li r0, 0
stw r0, 8(r12)
mtRunGateDone:
stw r11, 0(r29)
blr
; mtRunB: 0 switch (1 = the right B only runs, 0 = B also attacks as before), 4 B alone holds X on this read, 8 an X press to put in on the next pad update (the attack gesture),
; 12 B is pressing X on this read, 16 something else (right trigger, left X, the attack gesture) is.
mtRunB:
.int 1
.int 0
.int 0
.int 0
.int 0
; mtMic: 0 blow switch (1 = the hand at the mouth counts as blowing, 0 = off), 4 the blowing flag
; (runtime), 8 the loudness reported while blowing (float; the game's own scale runs to about 4096,
; its 'sound' threshold is 550), 12 how close the hand must be to the head point, squared (units,
; 400 = about 27 cm), 16 how far above the head point the hand may be (float, units), 20 running
; counter, 24 counter value from which it counts (3 reads), 28 the counter's ceiling (8).
; The rest are counters for the launcher's summary: 32 / 36 / 40 how often the game asked the
; three microphone questions, 44 how many of those were answered with a blow, 48 how often the
; gesture turned on, 52 'MMIC', 56 which controller blows: its place in mtPad (16 = left, 88 = right).
mtMic:
.int 1
.int 0
.int 0x453B8000
.int 0x481C4000
.int 0x41F00000
.int 0
.int 3
.int 8
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0x4D4D4943
.int 16
; mtCam: 0 switch (1 = the horizontal limits below are used, 0 = the game's own), 4 and 8 the
; horizontal minimum and maximum in degrees (floats; -180 / +180 lets the right stick turn the
; diorama camera a whole half turn each way in 45-degree steps).
mtCam:
.int 1
.int 0xC3340000
.int 0x43340000
; mtZoom: 0 switch (1 = the right stick's up-down changes the camera distance while the camera is
; behind Mario), 4 how much per pad read at full push (game units, float; 150 units = 1 m), 8 the
; closest and 12 the farthest distance allowed, 16 the dead zone of the stick (0..1).
mtZoom:
.int 1
.int 0x3FC00000
.int 0x42A00000
.int 0x44160000
.int 0x3E800000
; mtLift: 0 the basic camera distance (float, 200): the part of the distance beyond it goes level and up;
; 4 how much it goes up per unit of that extra distance (float, 0.5 = 0.5 game units up for every 1 back).
mtLift:
.int 0x43480000
.int 0x3F000000
; mtHandW: the last world matrix computed for each glove (left 0.., right 48..), then the two
; 'computed' flags at 96 and 100, at 104 the switch for the held fireball (1 = its origin
; follows the right glove, 0 = original), at 108 the switch for the thrown fireball's
; direction (2 = it flies the way the right controller points on the ground plane, 1 = the full
; 3D way, 0 = original) and at 112/116/120 that pointing direction (unit vector in the game
; world, float); 124 the smallest horizontal part (squared) that mode 2 accepts, 128 = 0.5,
; 132 = 1.5 (constants).
mtHandW:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 1
.int 2
.int 0
.int 0
.int 0
.int 0x3D23D70A
.int 0x3F000000
.int 0x3FC00000
; mtHandVel: per hand (left, right) 32 bytes: 0/4/8 the hand position at the previous frame,
; 12 its valid flag, 16/20/24 the movement between the last two different samples.
mtHandVel:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
mtNearState:
.int 0
.int 0
.int 0
.int 0
.int 0x41200000
.int 0x00000000

mtPad:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0

mtMotionData:
.int 0x3CB851EC
.int 0x4845C100
.int 0x3F000000
.int 0xBF000000
.int 0x00000000
.int 0xC3960000 ; +20 the left hand at most 300 units (20 cm) below the head for the D-pad gesture

; Depth of field off: take the branch the game takes when its own switch is
; clear, so the pass is never entered and r8 keeps the previous target.
0x024AD714 = mtDofSkip:
0x024AD708 = b mtDofSkip

; Glare off: take the branch the game takes when the flare filter's own switch
; is clear, so the effect is never entered and r30 keeps the current target.
0x022D874C = mtGlareSkip:
0x022D86B8 = b mtGlareSkip

; Light shafts off: take the branch the game takes when the god ray reports
; nothing to do, so the effect is never entered and r30 keeps the target.
0x022D8690 = mtGodRaySkip:
0x022D85CC = b mtGodRaySkip

; ---- Visibility and transitions (from Alpha 1.4): title / file-select wipes on the menu canvas (ts*), world-map and bonus-room filters, effect flare filter (pf*) ----
tsScene:
.int 0
tsStats:
.int 0
.int 0
.int 0
.int 0

pfGate:
stwu r1, -0x40(r1)
stw r4, 8(r1)
stw r5, 12(r1)
stw r6, 16(r1)
stw r7, 20(r1)
stw r8, 24(r1)
stw r9, 28(r1)
stw r10, 32(r1)
stw r11, 36(r1)
stw r12, 40(r1)
lis r12, pfState@ha
addi r12, r12, pfState@l
li r0, 0
stw r0, 24(r12)
lis r9, mrSceneClass@ha
lwz r9, mrSceneClass@l(r9)
lis r8, 0x1027
ori r8, r8, 0xF388
cmpw r9, r8
bne pfW2RoomPass
lwz r9, 12(r12)
cmpwi r9, 1
beq pfW2RoomName
cmpwi r9, 2
bne pfW2RoomPass
pfW2RoomName:
lbz r0, 36(r3)
cmpwi r0, 79
bne pfW2RoomWater
lbz r0, 37(r3)
cmpwi r0, 98
bne pfW2RoomWater
lbz r0, 38(r3)
cmpwi r0, 106
bne pfW2RoomWater
lbz r0, 39(r3)
cmpwi r0, 101
bne pfW2RoomWater
lbz r0, 40(r3)
cmpwi r0, 99
bne pfW2RoomWater
lbz r0, 41(r3)
cmpwi r0, 116
bne pfW2RoomWater
lbz r0, 42(r3)
cmpwi r0, 68
bne pfW2RoomWater
lbz r0, 43(r3)
cmpwi r0, 97
bne pfW2RoomWater
lbz r0, 44(r3)
cmpwi r0, 116
bne pfW2RoomWater
lbz r0, 45(r3)
cmpwi r0, 97
bne pfW2RoomWater
lbz r0, 46(r3)
cmpwi r0, 47
bne pfW2RoomWater
lbz r0, 47(r3)
cmpwi r0, 67
bne pfW2RoomWater
lbz r0, 48(r3)
cmpwi r0, 111
bne pfW2RoomWater
lbz r0, 49(r3)
cmpwi r0, 117
bne pfW2RoomWater
lbz r0, 50(r3)
cmpwi r0, 114
bne pfW2RoomWater
lbz r0, 51(r3)
cmpwi r0, 115
bne pfW2RoomWater
lbz r0, 52(r3)
cmpwi r0, 101
bne pfW2RoomWater
lbz r0, 53(r3)
cmpwi r0, 83
bne pfW2RoomWater
lbz r0, 54(r3)
cmpwi r0, 101
bne pfW2RoomWater
lbz r0, 55(r3)
cmpwi r0, 108
bne pfW2RoomWater
lbz r0, 56(r3)
cmpwi r0, 101
bne pfW2RoomWater
lbz r0, 57(r3)
cmpwi r0, 99
bne pfW2RoomWater
lbz r0, 58(r3)
cmpwi r0, 116
bne pfW2RoomWater
lbz r0, 59(r3)
cmpwi r0, 85
bne pfW2RoomWater
lbz r0, 60(r3)
cmpwi r0, 110
bne pfW2RoomWater
lbz r0, 61(r3)
cmpwi r0, 100
bne pfW2RoomWater
lbz r0, 62(r3)
cmpwi r0, 101
bne pfW2RoomWater
lbz r0, 63(r3)
cmpwi r0, 114
bne pfW2RoomWater
lbz r0, 64(r3)
cmpwi r0, 71
bne pfW2RoomWater
lbz r0, 65(r3)
cmpwi r0, 114
bne pfW2RoomWater
lbz r0, 66(r3)
cmpwi r0, 111
bne pfW2RoomWater
lbz r0, 67(r3)
cmpwi r0, 117
bne pfW2RoomWater
lbz r0, 68(r3)
cmpwi r0, 110
bne pfW2RoomWater
lbz r0, 69(r3)
cmpwi r0, 100
bne pfW2RoomWater
lbz r0, 70(r3)
cmpwi r0, 65
bne pfW2RoomWater
lbz r0, 71(r3)
cmpwi r0, 0
bne pfW2RoomWater
b pfW2RoomPlayer
pfW2RoomWater:
lbz r0, 36(r3)
cmpwi r0, 79
bne pfW2RoomPass
lbz r0, 37(r3)
cmpwi r0, 98
bne pfW2RoomPass
lbz r0, 38(r3)
cmpwi r0, 106
bne pfW2RoomPass
lbz r0, 39(r3)
cmpwi r0, 101
bne pfW2RoomPass
lbz r0, 40(r3)
cmpwi r0, 99
bne pfW2RoomPass
lbz r0, 41(r3)
cmpwi r0, 116
bne pfW2RoomPass
lbz r0, 42(r3)
cmpwi r0, 68
bne pfW2RoomPass
lbz r0, 43(r3)
cmpwi r0, 97
bne pfW2RoomPass
lbz r0, 44(r3)
cmpwi r0, 116
bne pfW2RoomPass
lbz r0, 45(r3)
cmpwi r0, 97
bne pfW2RoomPass
lbz r0, 46(r3)
cmpwi r0, 47
bne pfW2RoomPass
lbz r0, 47(r3)
cmpwi r0, 67
bne pfW2RoomPass
lbz r0, 48(r3)
cmpwi r0, 111
bne pfW2RoomPass
lbz r0, 49(r3)
cmpwi r0, 117
bne pfW2RoomPass
lbz r0, 50(r3)
cmpwi r0, 114
bne pfW2RoomPass
lbz r0, 51(r3)
cmpwi r0, 115
bne pfW2RoomPass
lbz r0, 52(r3)
cmpwi r0, 101
bne pfW2RoomPass
lbz r0, 53(r3)
cmpwi r0, 83
bne pfW2RoomPass
lbz r0, 54(r3)
cmpwi r0, 101
bne pfW2RoomPass
lbz r0, 55(r3)
cmpwi r0, 108
bne pfW2RoomPass
lbz r0, 56(r3)
cmpwi r0, 101
bne pfW2RoomPass
lbz r0, 57(r3)
cmpwi r0, 99
bne pfW2RoomPass
lbz r0, 58(r3)
cmpwi r0, 116
bne pfW2RoomPass
lbz r0, 59(r3)
cmpwi r0, 87
bne pfW2RoomPass
lbz r0, 60(r3)
cmpwi r0, 97
bne pfW2RoomPass
lbz r0, 61(r3)
cmpwi r0, 118
bne pfW2RoomPass
lbz r0, 62(r3)
cmpwi r0, 101
bne pfW2RoomPass
lbz r0, 63(r3)
cmpwi r0, 85
bne pfW2RoomPass
lbz r0, 64(r3)
cmpwi r0, 110
bne pfW2RoomPass
lbz r0, 65(r3)
cmpwi r0, 100
bne pfW2RoomPass
lbz r0, 66(r3)
cmpwi r0, 101
bne pfW2RoomPass
lbz r0, 67(r3)
cmpwi r0, 114
bne pfW2RoomPass
lbz r0, 68(r3)
cmpwi r0, 71
bne pfW2RoomPass
lbz r0, 69(r3)
cmpwi r0, 114
bne pfW2RoomPass
lbz r0, 70(r3)
cmpwi r0, 111
bne pfW2RoomPass
lbz r0, 71(r3)
cmpwi r0, 117
bne pfW2RoomPass
lbz r0, 72(r3)
cmpwi r0, 110
bne pfW2RoomPass
lbz r0, 73(r3)
cmpwi r0, 100
bne pfW2RoomPass
lbz r0, 74(r3)
cmpwi r0, 0
bne pfW2RoomPass
pfW2RoomPlayer:
lwz r8, 20(r12)
cmpwi r8, 0
beq pfW2RoomHide
lwz r8, 0xF0(r8)
cmpwi r8, 0
beq pfW2RoomHide
lwz r8, 0x28(r8)
cmpwi r8, 0
beq pfW2RoomHide
lwz r11, 0(r8)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfW2RoomHide
lwz r11, 4(r8)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfW2RoomHide
lwz r11, 8(r8)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfW2RoomHide
lwz r11, 0(r8)
lis r0, 0x466A
ori r0, r0, 0x6000
cmplw r11, r0
blt pfW2RoomHide
lis r0, 0x4690
ori r0, r0, 0x8800
cmplw r11, r0
bgt pfW2RoomHide
lwz r11, 4(r8)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x45BB
ori r0, r0, 0x8000
cmplw r11, r0
bgt pfW2RoomHide
lwz r11, 8(r8)
cmpwi r11, 0
bge pfW2RoomHide
rlwinm r11, r11, 0, 1, 31
lis r0, 0x458C
ori r0, r0, 0xA000
cmplw r11, r0
blt pfW2RoomHide
lis r0, 0x4614
ori r0, r0, 0x7000
cmplw r11, r0
bgt pfW2RoomHide
b pfW2RoomPass
pfW2RoomHide:
li r3, 0
b pfGateDone
pfW2RoomPass:

lwz r0, 8(r12)
cmpwi r0, 0
beq pfWorldOneAttachments
lbz r0, 36(r3)
cmpwi r0, 79
bne pfOtherModel
lbz r0, 37(r3)
cmpwi r0, 98
bne pfOtherModel
lbz r0, 38(r3)
cmpwi r0, 106
bne pfOtherModel
lbz r0, 39(r3)
cmpwi r0, 101
bne pfOtherModel
lbz r0, 40(r3)
cmpwi r0, 99
bne pfOtherModel
lbz r0, 41(r3)
cmpwi r0, 116
bne pfOtherModel
lbz r0, 42(r3)
cmpwi r0, 68
bne pfOtherModel
lbz r0, 43(r3)
cmpwi r0, 97
bne pfOtherModel
lbz r0, 44(r3)
cmpwi r0, 116
bne pfOtherModel
lbz r0, 45(r3)
cmpwi r0, 97
bne pfOtherModel
lbz r0, 46(r3)
cmpwi r0, 47
bne pfOtherModel
lbz r0, 47(r3)
cmpwi r0, 67
bne pfOtherModel
lbz r0, 48(r3)
cmpwi r0, 111
bne pfOtherModel
lbz r0, 49(r3)
cmpwi r0, 117
bne pfOtherModel
lbz r0, 50(r3)
cmpwi r0, 114
bne pfOtherModel
lbz r0, 51(r3)
cmpwi r0, 115
bne pfOtherModel
lbz r0, 52(r3)
cmpwi r0, 101
bne pfOtherModel
lbz r0, 53(r3)
cmpwi r0, 83
bne pfOtherModel
lbz r0, 54(r3)
cmpwi r0, 101
bne pfOtherModel
lbz r0, 55(r3)
cmpwi r0, 108
bne pfOtherModel
lbz r0, 56(r3)
cmpwi r0, 101
bne pfOtherModel
lbz r0, 57(r3)
cmpwi r0, 99
bne pfOtherModel
lbz r0, 58(r3)
cmpwi r0, 116
bne pfOtherModel
lbz r0, 59(r3)
cmpwi r0, 87
bne pfOtherModel
lbz r0, 60(r3)
cmpwi r0, 83
bne pfOtherModel
lbz r0, 61(r3)
cmpwi r0, 0
bne pfOtherModel
cmplwi r4, 13
bgt pfGateDone
lwz r8, 0(r3)
lhz r0, 0x14(r8)
cmpwi r0, 14
bne pfGateDone
lwz r8, 0x1C(r8)
mulli r9, r4, 48
add r8, r8, r9
lwz r8, 0(r8)
lwz r0, 0(r8)
lis r9, 0x4653
ori r9, r9, 0x4850
cmpw r0, r9
bne pfGateDone
lhz r0, 12(r8)
cmpw r0, r4
bne pfGateDone
lwz r9, 0x24(r8)
cmpwi r9, 0
beq pfGateDone
addi r8, r8, 0x24
add r8, r8, r9
lwz r0, 0(r8)
cmpwi r0, 4
bne pfGateDone
lwz r0, 4(r8)
cmpwi r0, 4
bne pfGateDone
lwz r0, 0x18(r8)
cmpwi r0, 0
bne pfGateDone
lis r9, pfRanges@ha
addi r9, r9, pfRanges@l
mulli r10, r4, 72
add r9, r9, r10
lwz r0, 0(r9)
lwz r10, 8(r8)
cmpw r0, r10
bne pfGateDone
lwz r0, 4(r9)
lhz r10, 12(r8)
cmpw r0, r10
bne pfGateDone
stw r8, 24(r12)
stw r4, 28(r12)
b pfGateDone
pfOtherModel:
lbz r0, 36(r3)
cmpwi r0, 79
bne pfPrefix0Next
lbz r0, 37(r3)
cmpwi r0, 98
bne pfPrefix0Next
lbz r0, 38(r3)
cmpwi r0, 106
bne pfPrefix0Next
lbz r0, 39(r3)
cmpwi r0, 101
bne pfPrefix0Next
lbz r0, 40(r3)
cmpwi r0, 99
bne pfPrefix0Next
lbz r0, 41(r3)
cmpwi r0, 116
bne pfPrefix0Next
lbz r0, 42(r3)
cmpwi r0, 68
bne pfPrefix0Next
lbz r0, 43(r3)
cmpwi r0, 97
bne pfPrefix0Next
lbz r0, 44(r3)
cmpwi r0, 116
bne pfPrefix0Next
lbz r0, 45(r3)
cmpwi r0, 97
bne pfPrefix0Next
lbz r0, 46(r3)
cmpwi r0, 47
bne pfPrefix0Next
lbz r0, 47(r3)
cmpwi r0, 67
bne pfPrefix0Next
lbz r0, 48(r3)
cmpwi r0, 111
bne pfPrefix0Next
lbz r0, 49(r3)
cmpwi r0, 117
bne pfPrefix0Next
lbz r0, 50(r3)
cmpwi r0, 114
bne pfPrefix0Next
lbz r0, 51(r3)
cmpwi r0, 115
bne pfPrefix0Next
lbz r0, 52(r3)
cmpwi r0, 101
bne pfPrefix0Next
lbz r0, 53(r3)
cmpwi r0, 83
bne pfPrefix0Next
lbz r0, 54(r3)
cmpwi r0, 101
bne pfPrefix0Next
lbz r0, 55(r3)
cmpwi r0, 108
bne pfPrefix0Next
lbz r0, 56(r3)
cmpwi r0, 101
bne pfPrefix0Next
lbz r0, 57(r3)
cmpwi r0, 99
bne pfPrefix0Next
lbz r0, 58(r3)
cmpwi r0, 116
bne pfPrefix0Next
b pfObjectPosition
pfPrefix0Next:
lbz r0, 36(r3)
cmpwi r0, 79
bne pfPrefix1Next
lbz r0, 37(r3)
cmpwi r0, 98
bne pfPrefix1Next
lbz r0, 38(r3)
cmpwi r0, 106
bne pfPrefix1Next
lbz r0, 39(r3)
cmpwi r0, 101
bne pfPrefix1Next
lbz r0, 40(r3)
cmpwi r0, 99
bne pfPrefix1Next
lbz r0, 41(r3)
cmpwi r0, 116
bne pfPrefix1Next
lbz r0, 42(r3)
cmpwi r0, 68
bne pfPrefix1Next
lbz r0, 43(r3)
cmpwi r0, 97
bne pfPrefix1Next
lbz r0, 44(r3)
cmpwi r0, 116
bne pfPrefix1Next
lbz r0, 45(r3)
cmpwi r0, 97
bne pfPrefix1Next
lbz r0, 46(r3)
cmpwi r0, 47
bne pfPrefix1Next
lbz r0, 47(r3)
cmpwi r0, 77
bne pfPrefix1Next
lbz r0, 48(r3)
cmpwi r0, 105
bne pfPrefix1Next
lbz r0, 49(r3)
cmpwi r0, 110
bne pfPrefix1Next
lbz r0, 50(r3)
cmpwi r0, 105
bne pfPrefix1Next
lbz r0, 51(r3)
cmpwi r0, 97
bne pfPrefix1Next
lbz r0, 52(r3)
cmpwi r0, 116
bne pfPrefix1Next
lbz r0, 53(r3)
cmpwi r0, 117
bne pfPrefix1Next
lbz r0, 54(r3)
cmpwi r0, 114
bne pfPrefix1Next
lbz r0, 55(r3)
cmpwi r0, 101
bne pfPrefix1Next
b pfObjectPosition
pfPrefix1Next:
lbz r0, 36(r3)
cmpwi r0, 79
bne pfPrefix2Next
lbz r0, 37(r3)
cmpwi r0, 98
bne pfPrefix2Next
lbz r0, 38(r3)
cmpwi r0, 106
bne pfPrefix2Next
lbz r0, 39(r3)
cmpwi r0, 101
bne pfPrefix2Next
lbz r0, 40(r3)
cmpwi r0, 99
bne pfPrefix2Next
lbz r0, 41(r3)
cmpwi r0, 116
bne pfPrefix2Next
lbz r0, 42(r3)
cmpwi r0, 68
bne pfPrefix2Next
lbz r0, 43(r3)
cmpwi r0, 97
bne pfPrefix2Next
lbz r0, 44(r3)
cmpwi r0, 116
bne pfPrefix2Next
lbz r0, 45(r3)
cmpwi r0, 97
bne pfPrefix2Next
lbz r0, 46(r3)
cmpwi r0, 47
bne pfPrefix2Next
lbz r0, 47(r3)
cmpwi r0, 67
bne pfPrefix2Next
lbz r0, 48(r3)
cmpwi r0, 111
bne pfPrefix2Next
lbz r0, 49(r3)
cmpwi r0, 97
bne pfPrefix2Next
lbz r0, 50(r3)
cmpwi r0, 115
bne pfPrefix2Next
lbz r0, 51(r3)
cmpwi r0, 116
bne pfPrefix2Next
lbz r0, 52(r3)
cmpwi r0, 101
bne pfPrefix2Next
lbz r0, 53(r3)
cmpwi r0, 114
bne pfPrefix2Next
lbz r0, 54(r3)
cmpwi r0, 83
bne pfPrefix2Next
lbz r0, 55(r3)
cmpwi r0, 116
bne pfPrefix2Next
lbz r0, 56(r3)
cmpwi r0, 97
bne pfPrefix2Next
lbz r0, 57(r3)
cmpwi r0, 114
bne pfPrefix2Next
b pfObjectPosition
pfPrefix2Next:
lbz r0, 36(r3)
cmpwi r0, 79
bne pfPrefix3Next
lbz r0, 37(r3)
cmpwi r0, 98
bne pfPrefix3Next
lbz r0, 38(r3)
cmpwi r0, 106
bne pfPrefix3Next
lbz r0, 39(r3)
cmpwi r0, 101
bne pfPrefix3Next
lbz r0, 40(r3)
cmpwi r0, 99
bne pfPrefix3Next
lbz r0, 41(r3)
cmpwi r0, 116
bne pfPrefix3Next
lbz r0, 42(r3)
cmpwi r0, 68
bne pfPrefix3Next
lbz r0, 43(r3)
cmpwi r0, 97
bne pfPrefix3Next
lbz r0, 44(r3)
cmpwi r0, 116
bne pfPrefix3Next
lbz r0, 45(r3)
cmpwi r0, 97
bne pfPrefix3Next
lbz r0, 46(r3)
cmpwi r0, 47
bne pfPrefix3Next
lbz r0, 47(r3)
cmpwi r0, 84
bne pfPrefix3Next
lbz r0, 48(r3)
cmpwi r0, 105
bne pfPrefix3Next
lbz r0, 49(r3)
cmpwi r0, 99
bne pfPrefix3Next
lbz r0, 50(r3)
cmpwi r0, 111
bne pfPrefix3Next
b pfObjectPosition
pfPrefix3Next:
b pfGateDone
pfObjectPosition:
addi r8, r3, 36
li r9, 64
pfNameEnd:
lbz r0, 0(r8)
cmpwi r0, 0
beq pfHaveNameEnd
addi r8, r8, 1
addi r9, r9, -1
cmpwi r9, 0
bgt pfNameEnd
b pfGateDone
pfHaveNameEnd:
addi r8, r8, 4
rlwinm r8, r8, 0, 0, 29
lwz r8, 28(r8)
lis r9, 0x46AB
ori r9, r9, 0xE000
cmplw r8, r9
blt pfGateDone
lis r9, 0x470E
ori r9, r9, 0x9400
cmplw r8, r9
bgt pfGateDone
lis r9, 0x46D0
ori r9, r9, 0x3400
cmplw r8, r9
blt pfObjectLower
lis r9, 0x46F7
ori r9, r9, 0xDA00
cmplw r8, r9
blt pfObjectMiddle
li r8, 3
b pfObjectCompare
pfObjectLower:
li r8, 1
b pfObjectCompare
pfObjectMiddle:
li r8, 2
pfObjectCompare:
lwz r0, 8(r12)
cmpw r0, r8
beq pfGateDone
lwz r9, 32(r12)
addi r9, r9, 1
stw r9, 32(r12)
li r3, 0
b pfGateDone
pfWorldOneAttachments:
; W1 node/rail Y range is -275..20; its pipe parts are all Y=120.
; Only distant elevated road/pipe models qualify, never clouds or scenery.
lis r9, mrSceneClass@ha
lwz r9, mrSceneClass@l(r9)
lis r8, 0x1027
ori r8, r8, 0xF388
cmpw r9, r8
bne pfGateDone
lwz r9, 12(r12)
cmpwi r9, 1
bne pfGateDone
lbz r0, 36(r3)
cmpwi r0, 79
bne pfW1Road
lbz r0, 37(r3)
cmpwi r0, 98
bne pfW1Road
lbz r0, 38(r3)
cmpwi r0, 106
bne pfW1Road
lbz r0, 39(r3)
cmpwi r0, 101
bne pfW1Road
lbz r0, 40(r3)
cmpwi r0, 99
bne pfW1Road
lbz r0, 41(r3)
cmpwi r0, 116
bne pfW1Road
lbz r0, 42(r3)
cmpwi r0, 68
bne pfW1Road
lbz r0, 43(r3)
cmpwi r0, 97
bne pfW1Road
lbz r0, 44(r3)
cmpwi r0, 116
bne pfW1Road
lbz r0, 45(r3)
cmpwi r0, 97
bne pfW1Road
lbz r0, 46(r3)
cmpwi r0, 47
bne pfW1Road
lbz r0, 47(r3)
cmpwi r0, 82
bne pfW1Road
lbz r0, 48(r3)
cmpwi r0, 111
bne pfW1Road
lbz r0, 49(r3)
cmpwi r0, 117
bne pfW1Road
lbz r0, 50(r3)
cmpwi r0, 116
bne pfW1Road
lbz r0, 51(r3)
cmpwi r0, 101
bne pfW1Road
lbz r0, 52(r3)
cmpwi r0, 68
bne pfW1Road
lbz r0, 53(r3)
cmpwi r0, 111
bne pfW1Road
lbz r0, 54(r3)
cmpwi r0, 107
bne pfW1Road
lbz r0, 55(r3)
cmpwi r0, 97
bne pfW1Road
lbz r0, 56(r3)
cmpwi r0, 110
bne pfW1Road
b pfW1Position
pfW1Road:
lbz r0, 36(r3)
cmpwi r0, 79
bne pfGateDone
lbz r0, 37(r3)
cmpwi r0, 98
bne pfGateDone
lbz r0, 38(r3)
cmpwi r0, 106
bne pfGateDone
lbz r0, 39(r3)
cmpwi r0, 101
bne pfGateDone
lbz r0, 40(r3)
cmpwi r0, 99
bne pfGateDone
lbz r0, 41(r3)
cmpwi r0, 116
bne pfGateDone
lbz r0, 42(r3)
cmpwi r0, 68
bne pfGateDone
lbz r0, 43(r3)
cmpwi r0, 97
bne pfGateDone
lbz r0, 44(r3)
cmpwi r0, 116
bne pfGateDone
lbz r0, 45(r3)
cmpwi r0, 97
bne pfGateDone
lbz r0, 46(r3)
cmpwi r0, 47
bne pfGateDone
lbz r0, 47(r3)
cmpwi r0, 67
bne pfGateDone
lbz r0, 48(r3)
cmpwi r0, 111
bne pfGateDone
lbz r0, 49(r3)
cmpwi r0, 117
bne pfGateDone
lbz r0, 50(r3)
cmpwi r0, 114
bne pfGateDone
lbz r0, 51(r3)
cmpwi r0, 115
bne pfGateDone
lbz r0, 52(r3)
cmpwi r0, 101
bne pfGateDone
lbz r0, 53(r3)
cmpwi r0, 83
bne pfGateDone
lbz r0, 54(r3)
cmpwi r0, 101
bne pfGateDone
lbz r0, 55(r3)
cmpwi r0, 108
bne pfGateDone
lbz r0, 56(r3)
cmpwi r0, 101
bne pfGateDone
lbz r0, 57(r3)
cmpwi r0, 99
bne pfGateDone
lbz r0, 58(r3)
cmpwi r0, 116
bne pfGateDone
lbz r0, 59(r3)
cmpwi r0, 82
bne pfGateDone
lbz r0, 60(r3)
cmpwi r0, 111
bne pfGateDone
lbz r0, 61(r3)
cmpwi r0, 97
bne pfGateDone
lbz r0, 62(r3)
cmpwi r0, 100
bne pfGateDone
pfW1Position:
addi r8, r3, 36
li r9, 64
pfW1NameEnd:
lbz r0, 0(r8)
cmpwi r0, 0
beq pfW1HaveName
addi r8, r8, 1
addi r9, r9, -1
cmpwi r9, 0
bgt pfW1NameEnd
b pfGateDone
pfW1HaveName:
addi r8, r8, 4
rlwinm r8, r8, 0, 0, 29
lwz r8, 28(r8)
lis r9, 0x44FA ; 2000.0: generous separation from all W1 road/pipe placements
cmplw r8, r9
blt pfGateDone
lis r9, 0x470E
ori r9, r9, 0x9400 ; 36500.0: unknown/nonfinite positions pass
cmplw r8, r9
bgt pfGateDone
lwz r9, 56(r12)
addi r9, r9, 1
stw r9, 56(r12)
li r3, 0
pfGateDone:
lwz r4, 8(r1)
lwz r5, 12(r1)
lwz r6, 16(r1)
lwz r7, 20(r1)
lwz r8, 24(r1)
lwz r9, 28(r1)
lwz r10, 32(r1)
lwz r11, 36(r1)
lwz r12, 40(r1)
addi r1, r1, 0x40
blr
pfDraw:
stwu r1, -0x80(r1)
mflr r0
stw r0, 0x84(r1)
stw r3, 8(r1)
stw r4, 12(r1)
stw r5, 16(r1)
stw r6, 20(r1)
stw r7, 24(r1)
stw r8, 28(r1)
stw r20, 32(r1)
stw r21, 36(r1)
stw r22, 40(r1)
stw r23, 44(r1)
stw r24, 48(r1)
stw r25, 52(r1)
stw r26, 56(r1)
stw r27, 60(r1)
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r9, 24(r12)
cmpw r9, r30
bne pfDrawOriginal
lwz r25, 8(r12)
cmplwi r25, 1
blt pfDrawOriginal
cmplwi r25, 3
bgt pfDrawOriginal
lwz r9, 28(r12)
cmplwi r9, 13
bgt pfDrawOriginal
cmpwi r3, 4
bne pfDrawOriginal
cmpwi r5, 4
bne pfDrawOriginal
cmpwi r7, 0
bne pfDrawOriginal
cmplwi r4, 0
beq pfDrawOriginal
andi. r0, r31, 1
bne pfDrawOriginal
lis r20, pfRanges@ha
addi r20, r20, pfRanges@l
mulli r9, r9, 72
add r20, r20, r9
srwi r22, r31, 1
add r23, r22, r4
cmplw r23, r22
blt pfDrawOriginal
lwz r0, 0(r20)
cmplw r23, r0
bgt pfDrawOriginal
subf r24, r31, r6
lwz r21, 8(r20)
addi r20, r20, 12
pfDrawLoop:
lwz r0, 0(r20)
cmpw r0, r25
bne pfDrawNext
lwz r26, 4(r20)
lwz r27, 8(r20)
add r27, r26, r27
cmplw r26, r22
bge pfDrawLoReady
mr r26, r22
pfDrawLoReady:
cmplw r27, r23
ble pfDrawHiReady
mr r27, r23
pfDrawHiReady:
cmplw r26, r27
bge pfDrawNext
lwz r3, 8(r1)
subf r4, r26, r27
lwz r5, 16(r1)
slwi r6, r26, 1
add r6, r6, r24
lwz r7, 24(r1)
lwz r8, 28(r1)
bl import.gx2.GX2DrawIndexedEx
pfDrawNext:
addi r20, r20, 12
addi r21, r21, -1
cmpwi r21, 0
bgt pfDrawLoop
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r11, 36(r12)
addi r11, r11, 1
stw r11, 36(r12)
b pfDrawDone
pfDrawOriginal:
lwz r3, 8(r1)
lwz r4, 12(r1)
lwz r5, 16(r1)
lwz r6, 20(r1)
lwz r7, 24(r1)
lwz r8, 28(r1)
bl import.gx2.GX2DrawIndexedEx
pfDrawDone:
lwz r20, 32(r1)
lwz r21, 36(r1)
lwz r22, 40(r1)
lwz r23, 44(r1)
lwz r24, 48(r1)
lwz r25, 52(r1)
lwz r26, 56(r1)
lwz r27, 60(r1)
lwz r0, 0x84(r1)
mtlr r0
addi r1, r1, 0x80
blr
pfState:
.int 0x50464C54
.int 1
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
pfRanges:
.int 6936
.int 15
.int 1
.int 2
.int 0
.int 6936
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 10845
.int 14
.int 1
.int 2
.int 0
.int 10845
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 7020
.int 17
.int 1
.int 1
.int 0
.int 7020
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 9894
.int 16
.int 1
.int 3
.int 0
.int 9894
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 16440
.int 20
.int 2
.int 2
.int 0
.int 12408
.int 1
.int 12408
.int 4032
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 7524
.int 15
.int 5
.int 2
.int 0
.int 12
.int 1
.int 12
.int 1737
.int 2
.int 1749
.int 201
.int 1
.int 1950
.int 99
.int 2
.int 2049
.int 5475
.int 8496
.int 24
.int 1
.int 2
.int 0
.int 8496
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 7824
.int 16
.int 1
.int 1
.int 0
.int 7824
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 13272
.int 22
.int 1
.int 2
.int 0
.int 13272
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 11520
.int 15
.int 1
.int 3
.int 0
.int 11520
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 7020
.int 17
.int 1
.int 1
.int 0
.int 7020
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 9894
.int 16
.int 1
.int 3
.int 0
.int 9894
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 6936
.int 15
.int 1
.int 2
.int 0
.int 6936
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 10845
.int 14
.int 1
.int 2
.int 0
.int 10845
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
pfParticleFill:
stwu r1, -0x30(r1)
mflr r0
stw r0, 0x34(r1)
stw r3, 8(r1)
stw r4, 12(r1)
bl pfParticleFillOriginal
lis r12, pfParticleDebug@ha
addi r12, r12, pfParticleDebug@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
lwz r10, 12(r1)
lwz r10, 0x12C(r10)
stw r10, 4(r12)
lwz r9, 0x130(r10)
stw r9, 8(r12)
lwz r11, 8(r1)
lwz r11, 4(r11)
stw r11, 12(r12)
lis r6, pfParticleCensus@ha
addi r6, r6, pfParticleCensus@l
srwi r8, r9, 4
rlwinm r8, r8, 6, 18, 25
li r7, 8
pfCensusProbe:
add r5, r6, r8
lwz r0, 0(r5)
cmpw r0, r9
beq pfCensusRecord
cmpwi r0, 0
beq pfCensusRecord
addi r8, r8, 64
rlwinm r8, r8, 0, 18, 25
addi r7, r7, -1
cmpwi r7, 0
bgt pfCensusProbe
lis r12, pfParticleDebug@ha
addi r12, r12, pfParticleDebug@l
lwz r4, 48(r12)
addi r4, r4, 1
stw r4, 48(r12)
b pfCensusDone
pfCensusRecord:
stw r9, 0(r5)
lwz r4, 4(r5)
addi r4, r4, 1
stw r4, 4(r5)
lis r11, mrSceneClass@ha
lwz r11, mrSceneClass@l(r11)
stw r11, 16(r5)
lis r0, 0x1027
ori r0, r0, 0xF388
cmpw r11, r0
bne pfCensusNotMap
lwz r4, 8(r5)
addi r4, r4, 1
stw r4, 8(r5)
b pfCensusMetadata
pfCensusNotMap:
lwz r4, 12(r5)
addi r4, r4, 1
stw r4, 12(r5)
pfCensusMetadata:
lwz r0, 0(r9)
stw r0, 20(r5)
lwz r0, 4(r9)
stw r0, 24(r5)
lwz r0, 0x38(r9)
stw r0, 28(r5)
lwz r0, 0x2E8(r9)
stw r0, 32(r5)
lwz r0, 0x3C(r9)
stw r0, 52(r5)
lwz r4, 12(r1)
stw r4, 60(r5)
lwz r0, 0x18(r4)
stw r0, 36(r5)
lwz r0, 0x12C(r4)
stw r0, 56(r5)
lwz r4, 8(r1)
lwz r0, 4(r4)
stw r0, 40(r5)
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r0, 12(r12)
stw r0, 44(r5)
lwz r0, 8(r12)
stw r0, 48(r5)
pfCensusDone:
lis r11, mrSceneClass@ha
lwz r11, mrSceneClass@l(r11)
lis r9, 0x1027
ori r9, r9, 0xF388
cmpw r11, r9
beq pfCensusGuardPassed
lis r12, pfParticleDebug@ha
addi r12, r12, pfParticleDebug@l
lwz r4, 44(r12)
addi r4, r4, 1
stw r4, 44(r12)
b pfParticleDone
pfCensusGuardPassed:
lis r12, pfParticleDebug@ha
addi r12, r12, pfParticleDebug@l
lwz r4, 40(r12)
addi r4, r4, 1
stw r4, 40(r12)
; Particle +12C owns the emitter, independent of the caller's GPR allocation.
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r8, 8(r12)
lwz r10, 12(r1)
lwz r10, 0x12C(r10)
lwz r9, 0x130(r10)
cmpwi r9, 0
beq pfParticleDone
; Road Glow is independent from the model draw and has four definitions.
lwz r11, 0x38(r9)
cmplwi r11, 0x3F0C
beq pfRoadGlow
cmplwi r11, 0x3F11
beq pfRoadPtcl
cmplwi r11, 0x3F16
beq pfRoadCore
cmplwi r11, 0x3F1B
beq pfRoadCore
cmplwi r8, 1
blt pfParticleDone
cmplwi r8, 3
bgt pfParticleDone
; Three unique tuples in the verified EU-v0 effect resource.
lwz r0, 0(r9)
cmpwi r0, 0
bne pfParticleDone
lwz r0, 4(r9)
lis r10, 0x0080
cmpw r0, r10
bne pfParticleDone
lwz r10, 0x2E8(r9)
lwz r11, 0x38(r9)
cmpwi r10, 152
beq pfParticleA
cmpwi r10, 153
beq pfParticleB
cmpwi r10, 154
bne pfParticleDone
cmplwi r11, 0xA289
bne pfParticleDone
b pfParticlePosition
pfParticleA:
cmplwi r11, 0xA27D
bne pfParticleDone
b pfParticlePosition
pfParticleB:
cmplwi r11, 0xA283
bne pfParticleDone
pfParticlePosition:
lis r11, pfParticleDebug@ha
addi r11, r11, pfParticleDebug@l
lwz r4, 16(r11)
addi r4, r4, 1
stw r4, 16(r11)
stw r9, 24(r11)
lwz r11, 40(r12)
addi r11, r11, 1
stw r11, 40(r12)
; Classify FallPtcl in its primitive's local space, before native transform.
; The verified source meshes lie at -8.40, 4790.73 and 10140.73.
; 0254D070..0254D0F0 applies particle+104 to local +14/+18/+1C.
lwz r9, 12(r1)
lwz r10, 0x18(r9)
lis r11, pfParticleDebug@ha
addi r11, r11, pfParticleDebug@l
stw r10, 28(r11)
stw r10, 48(r12)
lwz r11, 12(r1)
lwz r11, 0x12C(r11)
stw r11, 52(r12)
cmpwi r10, 0
bge pfParticlePositiveLocal
rlwinm r10, r10, 0, 1, 31
lis r11, 0x44FA ; permit local negative drift only down to -2000
cmplw r10, r11
bgt pfParticleDone
b pfParticleLower
pfParticlePositiveLocal:
lis r11, 0x463F
ori r11, r11, 0x6800 ; 12250; NaN/Inf and unknown positions pass
cmplw r10, r11
bgt pfParticleDone
lis r11, 0x4516 ; 2400
cmplw r10, r11
blt pfParticleLower
lis r11, 0x45E9
ori r11, r11, 0x9800 ; 7475
cmplw r10, r11
blt pfParticleMiddle
li r10, 3
b pfParticleCompare
pfRoadGlow:
lwz r0, 0(r9)
cmpwi r0, 1
bne pfParticleDone
lwz r0, 4(r9)
lis r11, 0x0038
cmpw r0, r11
bne pfParticleDone
b pfRoadIdentity
pfRoadPtcl:
lwz r0, 0(r9)
cmpwi r0, 1
bne pfParticleDone
b pfRoadZeroFlags
pfRoadCore:
lwz r0, 0(r9)
cmpwi r0, 0
bne pfParticleDone
pfRoadZeroFlags:
lwz r0, 4(r9)
cmpwi r0, 0
bne pfParticleDone
pfRoadIdentity:
lwz r0, 0x2E8(r9)
cmpwi r0, -1
bne pfParticleDone
lis r11, pfParticleDebug@ha
addi r11, r11, pfParticleDebug@l
lwz r4, 20(r11)
addi r4, r4, 1
stw r4, 20(r11)
stw r9, 32(r11)
lwz r11, 40(r12)
addi r11, r11, 1
stw r11, 40(r12)
; Road effects follow their owner's position. Classify native world output.
lwz r9, 8(r1)
lwz r10, 4(r9)
lis r11, pfParticleDebug@ha
addi r11, r11, pfParticleDebug@l
stw r10, 36(r11)
stw r10, 48(r12)
cmplwi r8, 1
blt pfRoadWorldOne
cmplwi r8, 3
bgt pfParticleDone
lis r11, 0x46AB
ori r11, r11, 0xE000 ; 22000
cmplw r10, r11
blt pfParticleDone
lis r11, 0x470E
ori r11, r11, 0x9400 ; 36500
cmplw r10, r11
bgt pfParticleDone
lis r11, 0x46D0
ori r11, r11, 0x3400 ; 26650
cmplw r10, r11
blt pfParticleLower
lis r11, 0x46F7
ori r11, r11, 0xDA00 ; 31725
cmplw r10, r11
blt pfParticleMiddle
li r10, 3
b pfParticleCompare
pfParticleLower:
li r10, 1
b pfParticleCompare
pfParticleMiddle:
li r10, 2
pfParticleCompare:
cmpw r10, r8
beq pfParticleDone
b pfParticleHide
pfRoadWorldOne:
lwz r11, 12(r12)
cmpwi r11, 1
bne pfParticleDone
lis r11, 0x44FA ; same distant-attachment bound as the W1 model filter
cmplw r10, r11
blt pfParticleDone
lis r11, 0x470E
ori r11, r11, 0x9400
cmplw r10, r11
bgt pfParticleDone
pfParticleHide:
lwz r9, 8(r1)
; Only this frame's 0xC0-byte GPU record. Scale xy and both colour alphas.
li r0, 0
stw r0, 0x10(r9)
stw r0, 0x14(r9)
stw r0, 0x2C(r9)
stw r0, 0x3C(r9)
lwz r11, 44(r12)
addi r11, r11, 1
stw r11, 44(r12)
pfParticleDone:
lwz r0, 0x34(r1)
mtlr r0
addi r1, r1, 0x30
blr
pfParticleDebug:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
pfParticleCensus:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
0x0254DF08 = pfParticleFillOriginal:
0x02558F78 = bla pfParticleFill
0x02548B3C = bla pfParticleFill
0x0255C220 = bla pfParticleFill
0x0255C2F8 = bla pfParticleFill
pfPipeActor:
stwu r1, -0x20(r1)
mflr r0
stw r0, 0x24(r1)
lis r12, pfPipeState@ha
addi r12, r12, pfPipeState@l
lwz r0, 0(r12)
stw r0, 8(r1)
li r0, 0
stw r0, 0(r12)
lis r10, mrSceneClass@ha
lwz r10, mrSceneClass@l(r10)
; First-stage capture: a rescued remote bonus room has a large Black01
; enclosure. Keep native visibility for this exact actor/model only; this
; still permits the room when the game's own camera accepts it.
lis r11, 0x1032
ori r11, r11, 0x86DC
cmpw r10, r11
bne pfPipeMapScene
lwz r9, 0(r3)
cmpwi r9, 0
beq pfPipeCall
lwz r11, 0(r9)
lis r0, 0x1037
ori r0, r0, 0x6518
cmpw r11, r0
bne pfPipeCall
lwz r9, 0x44(r9)
cmpwi r9, 0
beq pfPipeCall
lwz r9, 4(r9)
cmpwi r9, 0
beq pfPipeCall
lbz r0, 0(r9)
cmpwi r0, 69
bne pfPipeCall
lbz r0, 1(r9)
cmpwi r0, 110
bne pfPipeCall
lbz r0, 2(r9)
cmpwi r0, 116
bne pfPipeCall
lbz r0, 3(r9)
cmpwi r0, 101
bne pfPipeCall
lbz r0, 4(r9)
cmpwi r0, 114
bne pfPipeCall
lbz r0, 5(r9)
cmpwi r0, 67
bne pfPipeCall
lbz r0, 6(r9)
cmpwi r0, 97
bne pfPipeCall
lbz r0, 7(r9)
cmpwi r0, 116
bne pfPipeCall
lbz r0, 8(r9)
cmpwi r0, 77
bne pfPipeCall
lbz r0, 9(r9)
cmpwi r0, 97
bne pfPipeCall
lbz r0, 10(r9)
cmpwi r0, 114
bne pfPipeCall
lbz r0, 11(r9)
cmpwi r0, 105
bne pfPipeCall
lbz r0, 12(r9)
cmpwi r0, 111
bne pfPipeCall
lbz r0, 13(r9)
cmpwi r0, 66
bne pfPipeCall
lbz r0, 14(r9)
cmpwi r0, 111
bne pfPipeCall
lbz r0, 15(r9)
cmpwi r0, 110
bne pfPipeCall
lbz r0, 16(r9)
cmpwi r0, 117
bne pfPipeCall
lbz r0, 17(r9)
cmpwi r0, 115
bne pfPipeCall
lbz r0, 18(r9)
cmpwi r0, 82
bne pfPipeCall
lbz r0, 19(r9)
cmpwi r0, 111
bne pfPipeCall
lbz r0, 20(r9)
cmpwi r0, 111
bne pfPipeCall
lbz r0, 21(r9)
cmpwi r0, 109
bne pfPipeCall
lbz r0, 22(r9)
cmpwi r0, 0
bne pfPipeCall
b pfPipeFound
pfPipeMapScene:
lis r11, 0x1027
ori r11, r11, 0xF388
cmpw r10, r11
bne pfPipeCall
lwz r9, 0(r3)
cmpwi r9, 0
beq pfPipeCall
lwz r10, 0(r9)
; RouteDokan, CourseSelectRouteDokan, CourseSelectRouteDokan terminator.
lis r11, 0x1030
ori r11, r11, 0x5018
cmpw r10, r11
beq pfPipeFound
lis r11, 0x1027
ori r11, r11, 0xE918
cmpw r10, r11
beq pfPipeFound
lis r11, 0x1027
ori r11, r11, 0xEBF4
cmpw r10, r11
beq pfPipeFound
; Generic parts: only a verified model-resource name qualifies.
lwz r9, 0x44(r9)
cmpwi r9, 0
beq pfPipeCall
lwz r9, 0(r9)
cmpwi r9, 0
beq pfPipeCall
lwz r9, 8(r9)
cmpwi r9, 0
beq pfPipeCall
lis r10, pfState@ha
addi r10, r10, pfState@l
lwz r10, 12(r10)
cmpwi r10, 2
bne pfPipeW1Names
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2Families
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2Families
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2Families
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2Families
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2Families
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2Families
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2Families
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2Families
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2Families
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2Families
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2Families
lbz r0, 47(r9)
cmpwi r0, 82
bne pfW2Families
lbz r0, 48(r9)
cmpwi r0, 111
bne pfW2Families
lbz r0, 49(r9)
cmpwi r0, 117
bne pfW2Families
lbz r0, 50(r9)
cmpwi r0, 116
bne pfW2Families
lbz r0, 51(r9)
cmpwi r0, 101
bne pfW2Families
lbz r0, 52(r9)
cmpwi r0, 68
bne pfW2Families
lbz r0, 53(r9)
cmpwi r0, 111
bne pfW2Families
lbz r0, 54(r9)
cmpwi r0, 107
bne pfW2Families
lbz r0, 55(r9)
cmpwi r0, 97
bne pfW2Families
lbz r0, 56(r9)
cmpwi r0, 110
bne pfW2Families
b pfPipeFound
pfW2Families:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2NameNext0
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2NameNext0
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2NameNext0
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2NameNext0
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2NameNext0
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2NameNext0
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2NameNext0
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2NameNext0
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2NameNext0
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2NameNext0
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2NameNext0
lbz r0, 47(r9)
cmpwi r0, 67
bne pfW2NameNext0
lbz r0, 48(r9)
cmpwi r0, 111
bne pfW2NameNext0
lbz r0, 49(r9)
cmpwi r0, 117
bne pfW2NameNext0
lbz r0, 50(r9)
cmpwi r0, 114
bne pfW2NameNext0
lbz r0, 51(r9)
cmpwi r0, 115
bne pfW2NameNext0
lbz r0, 52(r9)
cmpwi r0, 101
bne pfW2NameNext0
lbz r0, 53(r9)
cmpwi r0, 83
bne pfW2NameNext0
lbz r0, 54(r9)
cmpwi r0, 101
bne pfW2NameNext0
lbz r0, 55(r9)
cmpwi r0, 108
bne pfW2NameNext0
lbz r0, 56(r9)
cmpwi r0, 101
bne pfW2NameNext0
lbz r0, 57(r9)
cmpwi r0, 99
bne pfW2NameNext0
lbz r0, 58(r9)
cmpwi r0, 116
bne pfW2NameNext0
lbz r0, 59(r9)
cmpwi r0, 82
bne pfW2NameNext0
lbz r0, 60(r9)
cmpwi r0, 111
bne pfW2NameNext0
lbz r0, 61(r9)
cmpwi r0, 97
bne pfW2NameNext0
lbz r0, 62(r9)
cmpwi r0, 100
bne pfW2NameNext0
b pfW2NameEndStart
pfW2NameNext0:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2NameNext1
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2NameNext1
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2NameNext1
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2NameNext1
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2NameNext1
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2NameNext1
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2NameNext1
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2NameNext1
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2NameNext1
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2NameNext1
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2NameNext1
lbz r0, 47(r9)
cmpwi r0, 67
bne pfW2NameNext1
lbz r0, 48(r9)
cmpwi r0, 111
bne pfW2NameNext1
lbz r0, 49(r9)
cmpwi r0, 117
bne pfW2NameNext1
lbz r0, 50(r9)
cmpwi r0, 114
bne pfW2NameNext1
lbz r0, 51(r9)
cmpwi r0, 115
bne pfW2NameNext1
lbz r0, 52(r9)
cmpwi r0, 101
bne pfW2NameNext1
lbz r0, 53(r9)
cmpwi r0, 83
bne pfW2NameNext1
lbz r0, 54(r9)
cmpwi r0, 101
bne pfW2NameNext1
lbz r0, 55(r9)
cmpwi r0, 108
bne pfW2NameNext1
lbz r0, 56(r9)
cmpwi r0, 101
bne pfW2NameNext1
lbz r0, 57(r9)
cmpwi r0, 99
bne pfW2NameNext1
lbz r0, 58(r9)
cmpwi r0, 116
bne pfW2NameNext1
lbz r0, 59(r9)
cmpwi r0, 80
bne pfW2NameNext1
lbz r0, 60(r9)
cmpwi r0, 111
bne pfW2NameNext1
lbz r0, 61(r9)
cmpwi r0, 105
bne pfW2NameNext1
lbz r0, 62(r9)
cmpwi r0, 110
bne pfW2NameNext1
lbz r0, 63(r9)
cmpwi r0, 116
bne pfW2NameNext1
b pfW2NameEndStart
pfW2NameNext1:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2NameNext2
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2NameNext2
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2NameNext2
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2NameNext2
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2NameNext2
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2NameNext2
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2NameNext2
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2NameNext2
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2NameNext2
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2NameNext2
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2NameNext2
lbz r0, 47(r9)
cmpwi r0, 67
bne pfW2NameNext2
lbz r0, 48(r9)
cmpwi r0, 111
bne pfW2NameNext2
lbz r0, 49(r9)
cmpwi r0, 117
bne pfW2NameNext2
lbz r0, 50(r9)
cmpwi r0, 114
bne pfW2NameNext2
lbz r0, 51(r9)
cmpwi r0, 115
bne pfW2NameNext2
lbz r0, 52(r9)
cmpwi r0, 101
bne pfW2NameNext2
lbz r0, 53(r9)
cmpwi r0, 83
bne pfW2NameNext2
lbz r0, 54(r9)
cmpwi r0, 101
bne pfW2NameNext2
lbz r0, 55(r9)
cmpwi r0, 108
bne pfW2NameNext2
lbz r0, 56(r9)
cmpwi r0, 101
bne pfW2NameNext2
lbz r0, 57(r9)
cmpwi r0, 99
bne pfW2NameNext2
lbz r0, 58(r9)
cmpwi r0, 116
bne pfW2NameNext2
lbz r0, 59(r9)
cmpwi r0, 85
bne pfW2NameNext2
lbz r0, 60(r9)
cmpwi r0, 110
bne pfW2NameNext2
lbz r0, 61(r9)
cmpwi r0, 100
bne pfW2NameNext2
lbz r0, 62(r9)
cmpwi r0, 101
bne pfW2NameNext2
lbz r0, 63(r9)
cmpwi r0, 114
bne pfW2NameNext2
lbz r0, 64(r9)
cmpwi r0, 71
bne pfW2NameNext2
lbz r0, 65(r9)
cmpwi r0, 114
bne pfW2NameNext2
lbz r0, 66(r9)
cmpwi r0, 111
bne pfW2NameNext2
lbz r0, 67(r9)
cmpwi r0, 117
bne pfW2NameNext2
lbz r0, 68(r9)
cmpwi r0, 110
bne pfW2NameNext2
lbz r0, 69(r9)
cmpwi r0, 100
bne pfW2NameNext2
b pfW2NameEndStart
pfW2NameNext2:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2NameNext3
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2NameNext3
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2NameNext3
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2NameNext3
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2NameNext3
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2NameNext3
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2NameNext3
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2NameNext3
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2NameNext3
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2NameNext3
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2NameNext3
lbz r0, 47(r9)
cmpwi r0, 67
bne pfW2NameNext3
lbz r0, 48(r9)
cmpwi r0, 111
bne pfW2NameNext3
lbz r0, 49(r9)
cmpwi r0, 117
bne pfW2NameNext3
lbz r0, 50(r9)
cmpwi r0, 114
bne pfW2NameNext3
lbz r0, 51(r9)
cmpwi r0, 115
bne pfW2NameNext3
lbz r0, 52(r9)
cmpwi r0, 101
bne pfW2NameNext3
lbz r0, 53(r9)
cmpwi r0, 83
bne pfW2NameNext3
lbz r0, 54(r9)
cmpwi r0, 101
bne pfW2NameNext3
lbz r0, 55(r9)
cmpwi r0, 108
bne pfW2NameNext3
lbz r0, 56(r9)
cmpwi r0, 101
bne pfW2NameNext3
lbz r0, 57(r9)
cmpwi r0, 99
bne pfW2NameNext3
lbz r0, 58(r9)
cmpwi r0, 116
bne pfW2NameNext3
lbz r0, 59(r9)
cmpwi r0, 87
bne pfW2NameNext3
lbz r0, 60(r9)
cmpwi r0, 97
bne pfW2NameNext3
lbz r0, 61(r9)
cmpwi r0, 118
bne pfW2NameNext3
lbz r0, 62(r9)
cmpwi r0, 101
bne pfW2NameNext3
lbz r0, 63(r9)
cmpwi r0, 85
bne pfW2NameNext3
lbz r0, 64(r9)
cmpwi r0, 110
bne pfW2NameNext3
lbz r0, 65(r9)
cmpwi r0, 100
bne pfW2NameNext3
lbz r0, 66(r9)
cmpwi r0, 101
bne pfW2NameNext3
lbz r0, 67(r9)
cmpwi r0, 114
bne pfW2NameNext3
lbz r0, 68(r9)
cmpwi r0, 71
bne pfW2NameNext3
lbz r0, 69(r9)
cmpwi r0, 114
bne pfW2NameNext3
lbz r0, 70(r9)
cmpwi r0, 111
bne pfW2NameNext3
lbz r0, 71(r9)
cmpwi r0, 117
bne pfW2NameNext3
lbz r0, 72(r9)
cmpwi r0, 110
bne pfW2NameNext3
lbz r0, 73(r9)
cmpwi r0, 100
bne pfW2NameNext3
b pfW2NameEndStart
pfW2NameNext3:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2NameNext4
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2NameNext4
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2NameNext4
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2NameNext4
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2NameNext4
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2NameNext4
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2NameNext4
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2NameNext4
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2NameNext4
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2NameNext4
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2NameNext4
lbz r0, 47(r9)
cmpwi r0, 67
bne pfW2NameNext4
lbz r0, 48(r9)
cmpwi r0, 111
bne pfW2NameNext4
lbz r0, 49(r9)
cmpwi r0, 117
bne pfW2NameNext4
lbz r0, 50(r9)
cmpwi r0, 114
bne pfW2NameNext4
lbz r0, 51(r9)
cmpwi r0, 115
bne pfW2NameNext4
lbz r0, 52(r9)
cmpwi r0, 101
bne pfW2NameNext4
lbz r0, 53(r9)
cmpwi r0, 83
bne pfW2NameNext4
lbz r0, 54(r9)
cmpwi r0, 101
bne pfW2NameNext4
lbz r0, 55(r9)
cmpwi r0, 108
bne pfW2NameNext4
lbz r0, 56(r9)
cmpwi r0, 101
bne pfW2NameNext4
lbz r0, 57(r9)
cmpwi r0, 99
bne pfW2NameNext4
lbz r0, 58(r9)
cmpwi r0, 116
bne pfW2NameNext4
lbz r0, 59(r9)
cmpwi r0, 87
bne pfW2NameNext4
b pfW2NameEndStart
pfW2NameNext4:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2NameNext5
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2NameNext5
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2NameNext5
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2NameNext5
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2NameNext5
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2NameNext5
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2NameNext5
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2NameNext5
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2NameNext5
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2NameNext5
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2NameNext5
lbz r0, 47(r9)
cmpwi r0, 77
bne pfW2NameNext5
lbz r0, 48(r9)
cmpwi r0, 105
bne pfW2NameNext5
lbz r0, 49(r9)
cmpwi r0, 110
bne pfW2NameNext5
lbz r0, 50(r9)
cmpwi r0, 105
bne pfW2NameNext5
lbz r0, 51(r9)
cmpwi r0, 97
bne pfW2NameNext5
lbz r0, 52(r9)
cmpwi r0, 116
bne pfW2NameNext5
lbz r0, 53(r9)
cmpwi r0, 117
bne pfW2NameNext5
lbz r0, 54(r9)
cmpwi r0, 114
bne pfW2NameNext5
lbz r0, 55(r9)
cmpwi r0, 101
bne pfW2NameNext5
b pfW2NameEndStart
pfW2NameNext5:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfW2NameNext6
lbz r0, 37(r9)
cmpwi r0, 98
bne pfW2NameNext6
lbz r0, 38(r9)
cmpwi r0, 106
bne pfW2NameNext6
lbz r0, 39(r9)
cmpwi r0, 101
bne pfW2NameNext6
lbz r0, 40(r9)
cmpwi r0, 99
bne pfW2NameNext6
lbz r0, 41(r9)
cmpwi r0, 116
bne pfW2NameNext6
lbz r0, 42(r9)
cmpwi r0, 68
bne pfW2NameNext6
lbz r0, 43(r9)
cmpwi r0, 97
bne pfW2NameNext6
lbz r0, 44(r9)
cmpwi r0, 116
bne pfW2NameNext6
lbz r0, 45(r9)
cmpwi r0, 97
bne pfW2NameNext6
lbz r0, 46(r9)
cmpwi r0, 47
bne pfW2NameNext6
lbz r0, 47(r9)
cmpwi r0, 70
bne pfW2NameNext6
lbz r0, 48(r9)
cmpwi r0, 97
bne pfW2NameNext6
lbz r0, 49(r9)
cmpwi r0, 105
bne pfW2NameNext6
lbz r0, 50(r9)
cmpwi r0, 114
bne pfW2NameNext6
lbz r0, 51(r9)
cmpwi r0, 121
bne pfW2NameNext6
lbz r0, 52(r9)
cmpwi r0, 80
bne pfW2NameNext6
lbz r0, 53(r9)
cmpwi r0, 114
bne pfW2NameNext6
lbz r0, 54(r9)
cmpwi r0, 105
bne pfW2NameNext6
lbz r0, 55(r9)
cmpwi r0, 110
bne pfW2NameNext6
lbz r0, 56(r9)
cmpwi r0, 99
bne pfW2NameNext6
lbz r0, 57(r9)
cmpwi r0, 101
bne pfW2NameNext6
lbz r0, 58(r9)
cmpwi r0, 115
bne pfW2NameNext6
lbz r0, 59(r9)
cmpwi r0, 115
bne pfW2NameNext6
b pfW2NameEndStart
pfW2NameNext6:
b pfPipeCall
pfW2NameEndStart:
addi r10, r9, 36
li r11, 64
pfW2NameEnd:
lbz r0, 0(r10)
cmpwi r0, 0
beq pfW2Matrix
addi r10, r10, 1
addi r11, r11, -1
cmpwi r11, 0
bgt pfW2NameEnd
b pfPipeCall
pfW2Matrix:
addi r10, r10, 4
rlwinm r10, r10, 0, 0, 29
lwz r11, 12(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfPipeCall
lwz r11, 28(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfPipeCall
lwz r11, 44(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfPipeCall
lwz r11, 12(r10)
lis r0, 0x453B
ori r0, r0, 0x8000
cmplw r11, r0
blt pfRoadFound
lis r0, 0x4633
ori r0, r0, 0xB000
cmplw r11, r0
bgt pfRoadFound
lwz r11, 28(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x453B
ori r0, r0, 0x8000
cmplw r11, r0
bgt pfRoadFound
lwz r11, 44(r10)
cmpwi r11, 0
bge pfRoadFound
rlwinm r11, r11, 0, 1, 31
lis r0, 0x447A
ori r0, r0, 0x0000
cmplw r11, r0
blt pfRoadFound
lis r0, 0x4604
ori r0, r0, 0xD000
cmplw r11, r0
bgt pfRoadFound
b pfPipeCall
pfPipeW1Names:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfPipeRoadCheck
lbz r0, 37(r9)
cmpwi r0, 98
bne pfPipeRoadCheck
lbz r0, 38(r9)
cmpwi r0, 106
bne pfPipeRoadCheck
lbz r0, 39(r9)
cmpwi r0, 101
bne pfPipeRoadCheck
lbz r0, 40(r9)
cmpwi r0, 99
bne pfPipeRoadCheck
lbz r0, 41(r9)
cmpwi r0, 116
bne pfPipeRoadCheck
lbz r0, 42(r9)
cmpwi r0, 68
bne pfPipeRoadCheck
lbz r0, 43(r9)
cmpwi r0, 97
bne pfPipeRoadCheck
lbz r0, 44(r9)
cmpwi r0, 116
bne pfPipeRoadCheck
lbz r0, 45(r9)
cmpwi r0, 97
bne pfPipeRoadCheck
lbz r0, 46(r9)
cmpwi r0, 47
bne pfPipeRoadCheck
lbz r0, 47(r9)
cmpwi r0, 82
bne pfPipeRoadCheck
lbz r0, 48(r9)
cmpwi r0, 111
bne pfPipeRoadCheck
lbz r0, 49(r9)
cmpwi r0, 117
bne pfPipeRoadCheck
lbz r0, 50(r9)
cmpwi r0, 116
bne pfPipeRoadCheck
lbz r0, 51(r9)
cmpwi r0, 101
bne pfPipeRoadCheck
lbz r0, 52(r9)
cmpwi r0, 68
bne pfPipeRoadCheck
lbz r0, 53(r9)
cmpwi r0, 111
bne pfPipeRoadCheck
lbz r0, 54(r9)
cmpwi r0, 107
bne pfPipeRoadCheck
lbz r0, 55(r9)
cmpwi r0, 97
bne pfPipeRoadCheck
lbz r0, 56(r9)
cmpwi r0, 110
bne pfPipeRoadCheck
b pfPipeFound
pfPipeRoadCheck:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfPipePointCheck
lbz r0, 37(r9)
cmpwi r0, 98
bne pfPipePointCheck
lbz r0, 38(r9)
cmpwi r0, 106
bne pfPipePointCheck
lbz r0, 39(r9)
cmpwi r0, 101
bne pfPipePointCheck
lbz r0, 40(r9)
cmpwi r0, 99
bne pfPipePointCheck
lbz r0, 41(r9)
cmpwi r0, 116
bne pfPipePointCheck
lbz r0, 42(r9)
cmpwi r0, 68
bne pfPipePointCheck
lbz r0, 43(r9)
cmpwi r0, 97
bne pfPipePointCheck
lbz r0, 44(r9)
cmpwi r0, 116
bne pfPipePointCheck
lbz r0, 45(r9)
cmpwi r0, 97
bne pfPipePointCheck
lbz r0, 46(r9)
cmpwi r0, 47
bne pfPipePointCheck
lbz r0, 47(r9)
cmpwi r0, 67
bne pfPipePointCheck
lbz r0, 48(r9)
cmpwi r0, 111
bne pfPipePointCheck
lbz r0, 49(r9)
cmpwi r0, 117
bne pfPipePointCheck
lbz r0, 50(r9)
cmpwi r0, 114
bne pfPipePointCheck
lbz r0, 51(r9)
cmpwi r0, 115
bne pfPipePointCheck
lbz r0, 52(r9)
cmpwi r0, 101
bne pfPipePointCheck
lbz r0, 53(r9)
cmpwi r0, 83
bne pfPipePointCheck
lbz r0, 54(r9)
cmpwi r0, 101
bne pfPipePointCheck
lbz r0, 55(r9)
cmpwi r0, 108
bne pfPipePointCheck
lbz r0, 56(r9)
cmpwi r0, 101
bne pfPipePointCheck
lbz r0, 57(r9)
cmpwi r0, 99
bne pfPipePointCheck
lbz r0, 58(r9)
cmpwi r0, 116
bne pfPipePointCheck
lbz r0, 59(r9)
cmpwi r0, 82
bne pfPipePointCheck
lbz r0, 60(r9)
cmpwi r0, 111
bne pfPipePointCheck
lbz r0, 61(r9)
cmpwi r0, 97
bne pfPipePointCheck
lbz r0, 62(r9)
cmpwi r0, 100
bne pfPipePointCheck
b pfPipeRouteBounds
pfPipePointCheck:
lbz r0, 36(r9)
cmpwi r0, 79
bne pfPipeCall
lbz r0, 37(r9)
cmpwi r0, 98
bne pfPipeCall
lbz r0, 38(r9)
cmpwi r0, 106
bne pfPipeCall
lbz r0, 39(r9)
cmpwi r0, 101
bne pfPipeCall
lbz r0, 40(r9)
cmpwi r0, 99
bne pfPipeCall
lbz r0, 41(r9)
cmpwi r0, 116
bne pfPipeCall
lbz r0, 42(r9)
cmpwi r0, 68
bne pfPipeCall
lbz r0, 43(r9)
cmpwi r0, 97
bne pfPipeCall
lbz r0, 44(r9)
cmpwi r0, 116
bne pfPipeCall
lbz r0, 45(r9)
cmpwi r0, 97
bne pfPipeCall
lbz r0, 46(r9)
cmpwi r0, 47
bne pfPipeCall
lbz r0, 47(r9)
cmpwi r0, 67
bne pfPipeCall
lbz r0, 48(r9)
cmpwi r0, 111
bne pfPipeCall
lbz r0, 49(r9)
cmpwi r0, 117
bne pfPipeCall
lbz r0, 50(r9)
cmpwi r0, 114
bne pfPipeCall
lbz r0, 51(r9)
cmpwi r0, 115
bne pfPipeCall
lbz r0, 52(r9)
cmpwi r0, 101
bne pfPipeCall
lbz r0, 53(r9)
cmpwi r0, 83
bne pfPipeCall
lbz r0, 54(r9)
cmpwi r0, 101
bne pfPipeCall
lbz r0, 55(r9)
cmpwi r0, 108
bne pfPipeCall
lbz r0, 56(r9)
cmpwi r0, 101
bne pfPipeCall
lbz r0, 57(r9)
cmpwi r0, 99
bne pfPipeCall
lbz r0, 58(r9)
cmpwi r0, 116
bne pfPipeCall
lbz r0, 59(r9)
cmpwi r0, 80
bne pfPipeCall
lbz r0, 60(r9)
cmpwi r0, 111
bne pfPipeCall
lbz r0, 61(r9)
cmpwi r0, 105
bne pfPipeCall
lbz r0, 62(r9)
cmpwi r0, 110
bne pfPipeCall
lbz r0, 63(r9)
cmpwi r0, 116
bne pfPipeCall
lbz r0, 64(r9)
cmpwi r0, 0
bne pfPipeCall
pfPipeRouteBounds:
; World 1 only: retain VR visibility on the local routes. Remote road
; segments still obey native rejection, just as in the successful grip test.
; Bonus-map filtering is deliberately unchanged.
lis r10, pfState@ha
addi r10, r10, pfState@l
lwz r10, 12(r10)
cmpwi r10, 1
bne pfPipeCall
addi r10, r9, 36
li r11, 64
pfRoadNameEnd:
lbz r0, 0(r10)
cmpwi r0, 0
beq pfRoadMatrix
addi r10, r10, 1
addi r11, r11, -1
cmpwi r11, 0
bgt pfRoadNameEnd
b pfPipeCall
pfRoadMatrix:
addi r10, r10, 4
rlwinm r10, r10, 0, 0, 29
; Validate all components first: unknown/nonfinite positions fail open.
lwz r11, 12(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000 ; 100000.0
cmplw r11, r0
bgt pfPipeCall
lwz r11, 28(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000 ; 100000.0
cmplw r11, r0
bgt pfPipeCall
lwz r11, 44(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000 ; 100000.0
cmplw r11, r0
bgt pfPipeCall
; Generous protected World-1 envelope around verified nodes and rails:
; X [-5000,5000], Y [-2000,2000], Z [0,5000]. Not a draw-distance cutoff:
; outside it only the extra VR rescue is disabled; native acceptance wins.
lwz r11, 12(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x459C
ori r0, r0, 0x4000 ; 5000.0
cmplw r11, r0
bgt pfRoadFound
lwz r11, 28(r10)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x44FA ; 2000.0
cmplw r11, r0
bgt pfRoadFound
lwz r11, 44(r10)
cmpwi r11, 0
blt pfRoadFound
lis r0, 0x459C
ori r0, r0, 0x4000
cmplw r11, r0
bgt pfRoadFound
b pfPipeCall
pfRoadFound:
lwz r11, 12(r12)
addi r11, r11, 1
stw r11, 12(r12)
pfPipeFound:

li r0, 1
stw r0, 0(r12)
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
pfPipeCall:
bl pfPipeNative
lis r12, pfPipeState@ha
addi r12, r12, pfPipeState@l
lwz r0, 8(r1)
stw r0, 0(r12)
lwz r0, 0x24(r1)
mtlr r0
addi r1, r1, 0x20
blr
pfPipeState:
.int 0
.int 0
.int 0
.int 0 ; remote World-1 road/point matches, separate from pipe body matches
0x0242F938 = pfPipeNative:
0x0242F984 = bla pfPipeActor
pfEffectDrawProbe:
stwu r1, -0x40(r1)
stw r0, 8(r1)
.int 0x7C000026
stw r0, 12(r1)
stw r3, 16(r1)
stw r4, 20(r1)
stw r5, 24(r1)
stw r6, 28(r1)
stw r7, 32(r1)
stw r8, 36(r1)
stw r9, 40(r1)
stw r10, 44(r1)
stw r11, 48(r1)
stw r12, 52(r1)
lis r12, pfEffectDrawState@ha
addi r12, r12, pfEffectDrawState@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
lis r10, mrSceneClass@ha
lwz r10, mrSceneClass@l(r10)
lis r0, 0x1027
ori r0, r0, 0xF388
cmpw r10, r0
bne pfEffectDrawDone
lwz r11, 4(r12)
addi r11, r11, 1
stw r11, 4(r12)
lwz r9, 0x130(r4)
cmpwi r9, 0
beq pfEffectDrawDone
lis r11, pfEffectDrawTable@ha
addi r11, r11, pfEffectDrawTable@l
srwi r8, r9, 4
rlwinm r8, r8, 6, 18, 25
li r7, 8
pfEffectDrawProbeSlot:
add r5, r11, r8
lwz r0, 0(r5)
cmpw r0, r9
beq pfEffectDrawRecord
cmpwi r0, 0
beq pfEffectDrawRecord
addi r8, r8, 64
rlwinm r8, r8, 0, 18, 25
addi r7, r7, -1
cmpwi r7, 0
bgt pfEffectDrawProbeSlot
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
b pfEffectDrawDone
pfEffectDrawRecord:
stw r9, 0(r5)
lwz r11, 4(r5)
addi r11, r11, 1
stw r11, 4(r5)
stw r4, 8(r5)
lwz r0, 0(r9)
stw r0, 12(r5)
lwz r0, 4(r9)
stw r0, 16(r5)
lwz r0, 0x38(r9)
stw r0, 20(r5)
lwz r0, 0x2E8(r9)
stw r0, 24(r5)
lwz r0, 0x3C(r9)
stw r0, 28(r5)
lwz r0, 0x2F8(r4)
stw r0, 32(r5)
lwz r0, 0x64(r4)
stw r0, 36(r5)
lwz r0, 0x2FC(r4)
stw r0, 40(r5)
lwz r0, 0x70(r4)
stw r0, 44(r5)
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r0, 12(r12)
stw r0, 48(r5)
lwz r0, 8(r12)
stw r0, 52(r5)
lwz r0, 28(r1) ; original r6: parent/child pass
stw r0, 56(r5)
lwz r0, 0xD4(r4) ; emitter matrix translation Y
stw r0, 60(r5)
pfEffectDrawDone:
lwz r3, 16(r1)
lwz r4, 20(r1)
lwz r5, 24(r1)
lwz r6, 28(r1)
lwz r7, 32(r1)
lwz r8, 36(r1)
lwz r9, 40(r1)
lwz r10, 44(r1)
lwz r11, 48(r1)
lwz r12, 52(r1)
lwz r0, 12(r1)
.int 0x7C0FF120
lwz r0, 8(r1)
addi r1, r1, 0x40
stwu r1, -0x70(r1)
b pfEffectDrawContinue
pfEffectDrawState:
.int 0
.int 0
.int 0
pfEffectDrawTable:
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
.int 0
0x0253F524 = pfEffectDrawContinue:
0x0253F520 = ba pfEffectDrawProbe
pfFlareStats:
.int 0
.int 0
.int 0
pfToadLampStats:
.int 0
pfEffectSubmit:
stwu r1, -0xA0(r1)
mflr r0
stw r0, 0xA4(r1)
stw r3, 8(r1)
stw r4, 12(r1)
stw r5, 16(r1)
stw r6, 20(r1)
stw r7, 24(r1)
stw r8, 28(r1)
stw r9, 32(r1)
stw r20, 40(r1)
stw r21, 44(r1)
stw r22, 48(r1)
stw r23, 52(r1)
stw r24, 56(r1)
stw r25, 60(r1)
stw r26, 64(r1)
stw r27, 68(r1)
stw r28, 72(r1)
stw r29, 76(r1)
stw r30, 80(r1)
stw r31, 84(r1)
; Captain Toad head ray: exact resource, effective FP, fresh nearby anchor.
lis r12, mrSceneClass@ha
lwz r12, mrSceneClass@l(r12)
lis r11, 0x1032
ori r11, r11, 0x86DC
cmpw r12, r11
bne pfToadLampContinue
lwz r10, 0x130(r31)
cmpwi r10, 0
beq pfToadLampContinue
lwz r11, 0(r10)
cmpwi r11, 0
bne pfToadLampContinue
lwz r11, 4(r10)
cmpwi r11, 0
bne pfToadLampContinue
lwz r11, 0x2E8(r10)
cmpwi r11, -1
bne pfToadLampContinue
lwz r11, 0x38(r10)
cmplwi r11, 0xD162
beq pfToadLampMode
cmplwi r11, 0xD169
bne pfToadLampContinue
pfToadLampMode:
lis r12, mtControl@ha
lwz r11, mtControl@l(r12)
cmpwi r11, 1
bne pfToadLampContinue
lis r12, rrSlot@ha
lwz r11, rrSlot@l(r12)
cmplwi r11, 1
bgt pfToadLampContinue
mulli r11, r11, 2
lis r12, rrEye@ha
lwz r10, rrEye@l(r12)
cmplwi r10, 1
bgt pfToadLampContinue
add r11, r11, r10
mulli r11, r11, 4
lis r12, mtNearState@ha
addi r12, r12, mtNearState@l
add r12, r12, r11
lwz r11, 0(r12)
cmpwi r11, 1
bne pfToadLampContinue
lis r12, mtHideModel@ha
addi r12, r12, mtHideModel@l
lwz r11, 16(r12)
cmplwi r11, 1
blt pfToadLampContinue
cmplwi r11, 17
bgt pfToadLampContinue
lwz r11, 12(r12)
lwz r10, 4(r12)
subf r11, r10, r11
cmplwi r11, 2
bgt pfToadLampContinue
; Save full FPR precision; original draw arguments are still in r3..r9.
stwu r1, -0x20(r1)
stfd f0, 8(r1)
stfd f1, 16(r1)
lis r12, mrEyeTarget@ha
addi r12, r12, mrEyeTarget@l
lfs f0, 0xC4(r31)
lfs f1, 0(r12)
fsubs f0, f0, f1
stfs f0, 24(r1)
lwz r11, 24(r1)
rlwinm r11, r11, 0, 1, 31
lis r10, 0x4348
cmplw r11, r10
bgt pfToadLampFar
lfs f0, 0xD4(r31)
lfs f1, 4(r12)
fsubs f0, f0, f1
stfs f0, 24(r1)
lwz r11, 24(r1)
rlwinm r11, r11, 0, 1, 31
lis r10, 0x4348
cmplw r11, r10
bgt pfToadLampFar
lfs f0, 0xE4(r31)
lfs f1, 8(r12)
fsubs f0, f0, f1
stfs f0, 24(r1)
lwz r11, 24(r1)
rlwinm r11, r11, 0, 1, 31
lis r10, 0x4348
cmplw r11, r10
bgt pfToadLampFar
li r10, 1
b pfToadLampRestore
pfToadLampFar:
li r10, 0
pfToadLampRestore:
lfd f0, 8(r1)
lfd f1, 16(r1)
addi r1, r1, 0x20
cmpwi r10, 0
beq pfToadLampContinue
lis r12, pfToadLampStats@ha
lwz r11, pfToadLampStats@l(r12)
addi r11, r11, 1
stw r11, pfToadLampStats@l(r12)
; Keep the native full feedback binding even when the colour draw is skipped.
cmpwi r8, 0
beq pfEffectDone
mr r5, r4
mr r4, r8
bl pfEffectBindNative
b pfEffectDone
pfToadLampContinue:
; ScreenLensFlareRight only, in StageScene. No map-state dependency.
lis r12, mrSceneClass@ha
lwz r12, mrSceneClass@l(r12)
lis r11, 0x1032
ori r11, r11, 0x86DC
cmpw r12, r11
beq pfScreenFlareStage
lis r11, 0x1027
ori r11, r11, 0xF388
cmpw r12, r11
bne pfScreenFlareContinue
lis r10, pfFlareStats@ha
addi r10, r10, pfFlareStats@l
lwz r11, 8(r10)
addi r11, r11, 1
stw r11, 8(r10)
b pfScreenFlareDefinition
pfScreenFlareStage:
pfScreenFlareDefinition:
lwz r10, 0x130(r31)
cmpwi r10, 0
beq pfScreenFlareContinue
lwz r11, 0(r10)
cmpwi r11, 0
bne pfScreenFlareContinue
lwz r11, 4(r10)
cmpwi r11, 0
bne pfScreenFlareContinue
lwz r11, 0x2E8(r10)
cmpwi r11, -1
bne pfScreenFlareContinue
lwz r11, 0x38(r10)
; Select the resource set by exact scene class; preserve sibling flare sets.
lis r10, 0x1027
ori r10, r10, 0xF388
cmpw r12, r10
beq pfScreenFlareMap
cmplwi r11, 0xD24F
beq pfScreenFlareSkip
cmplwi r11, 0xD259
beq pfScreenFlareSkip
cmplwi r11, 0xD267
beq pfScreenFlareSkip
b pfScreenFlareContinue
pfScreenFlareMap:
cmplwi r11, 0xE258
beq pfScreenFlareSkip
cmplwi r11, 0xE262
beq pfScreenFlareSkip
cmplwi r11, 0xE270
beq pfScreenFlareSkip
b pfScreenFlareContinue
pfScreenFlareSkip:
lis r10, pfFlareStats@ha
addi r10, r10, pfFlareStats@l
lis r11, 0x1027
ori r11, r11, 0xF388
cmpw r12, r11
bne pfScreenFlareCount
addi r10, r10, 4
pfScreenFlareCount:
lwz r11, 0(r10)
addi r11, r11, 1
stw r11, 0(r10)
; Preserve the full buffer binding required by native particle feedback.
; r8==0 means the caller already bound it; never filter the simulation.
cmpwi r8, 0
beq pfEffectDone
mr r5, r4
mr r4, r8
bl pfEffectBindNative
b pfEffectDone
pfScreenFlareContinue:
lis r12, mrSceneClass@ha
lwz r12, mrSceneClass@l(r12)
lis r11, 0x1027
ori r11, r11, 0xF388
cmpw r12, r11
bne pfEffectOriginal
; All four call sites retain the emitter in native r31.
lwz r10, 0x130(r31)
cmpwi r10, 0
beq pfEffectOriginal
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r11, 12(r12)
cmpwi r11, 2
bne pfW2FairyMiss
lwz r11, 0x2E8(r10)
cmpwi r11, -1
bne pfW2FairyMiss
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0001
cmpw r11, r12
bne pfW2FairyNext0
lwz r11, 4(r10)
lis r12, 0x0038
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext0
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0x20B9
cmpw r11, r12
bne pfW2FairyNext0
b pfW2FairyPosition
pfW2FairyNext0:
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext1
lwz r11, 4(r10)
lis r12, 0x0080
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext1
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0x20BE
cmpw r11, r12
bne pfW2FairyNext1
b pfW2FairyPosition
pfW2FairyNext1:
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0001
cmpw r11, r12
bne pfW2FairyNext2
lwz r11, 4(r10)
lis r12, 0x0038
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext2
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0xA661
cmpw r11, r12
bne pfW2FairyNext2
b pfW2FairyPosition
pfW2FairyNext2:
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext3
lwz r11, 4(r10)
lis r12, 0x0080
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext3
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0xA666
cmpw r11, r12
bne pfW2FairyNext3
b pfW2FairyPosition
pfW2FairyNext3:
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0001
cmpw r11, r12
bne pfW2FairyNext4
lwz r11, 4(r10)
lis r12, 0x0038
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext4
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0x690C
cmpw r11, r12
bne pfW2FairyNext4
b pfW2FairyPosition
pfW2FairyNext4:
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext5
lwz r11, 4(r10)
lis r12, 0x0080
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext5
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0x6911
cmpw r11, r12
bne pfW2FairyNext5
b pfW2FairyPosition
pfW2FairyNext5:
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0001
cmpw r11, r12
bne pfW2FairyNext6
lwz r11, 4(r10)
lis r12, 0x0038
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext6
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0xD5DD
cmpw r11, r12
bne pfW2FairyNext6
b pfW2FairyPosition
pfW2FairyNext6:
lwz r11, 0(r10)
lis r12, 0x0000
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext7
lwz r11, 4(r10)
lis r12, 0x0080
ori r12, r12, 0x0000
cmpw r11, r12
bne pfW2FairyNext7
lwz r11, 56(r10)
lis r12, 0x0000
ori r12, r12, 0xD5E2
cmpw r11, r12
bne pfW2FairyNext7
b pfW2FairyPosition
pfW2FairyNext7:
b pfW2FairyMiss
pfW2FairyPosition:
lwz r11, 196(r31)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfW2FairyMiss
lwz r11, 212(r31)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfW2FairyMiss
lwz r11, 228(r31)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x47C3
ori r0, r0, 0x5000
cmplw r11, r0
bgt pfW2FairyMiss
lwz r11, 196(r31)
lis r0, 0x453B
ori r0, r0, 0x8000
cmplw r11, r0
blt pfW2FairyHide
lis r0, 0x4633
ori r0, r0, 0xB000
cmplw r11, r0
bgt pfW2FairyHide
lwz r11, 212(r31)
rlwinm r11, r11, 0, 1, 31
lis r0, 0x453B
ori r0, r0, 0x8000
cmplw r11, r0
bgt pfW2FairyHide
lwz r11, 228(r31)
cmpwi r11, 0
bge pfW2FairyHide
rlwinm r11, r11, 0, 1, 31
lis r0, 0x447A
ori r0, r0, 0x0000
cmplw r11, r0
blt pfW2FairyHide
lis r0, 0x4604
ori r0, r0, 0xD000
cmplw r11, r0
bgt pfW2FairyHide
b pfW2FairyMiss
pfW2FairyHide:
cmpwi r8, 0
beq pfEffectDone
mr r5, r4
mr r4, r8
bl pfEffectBindNative
b pfEffectDone
pfW2FairyMiss:
lwz r11, 0x2E8(r10)
cmpwi r11, -1
bne pfAttachedMiss
lis r20, pfAttachedIdentities@ha
addi r20, r20, pfAttachedIdentities@l
li r21, 16
pfAttachedFind:
lwz r11, 0x38(r10)
lwz r12, 8(r20)
cmpw r11, r12
bne pfAttachedNext
lwz r11, 0(r10)
lwz r12, 0(r20)
cmpw r11, r12
bne pfAttachedNext
lwz r11, 4(r10)
lwz r12, 4(r20)
cmpw r11, r12
beq pfAttachedPosition
pfAttachedNext:
addi r20, r20, 12
addi r21, r21, -1
cmpwi r21, 0
bgt pfAttachedFind
b pfAttachedMiss
pfAttachedPosition:
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r22, 8(r12)
cmplwi r22, 1
blt pfEffectOriginal
cmplwi r22, 3
bgt pfEffectOriginal
lwz r11, 12(r12)
cmplwi r11, 9
blt pfEffectOriginal
cmplwi r11, 12
bgt pfEffectOriginal
lwz r11, 0xD4(r31)
lis r12, 0x46AB
ori r12, r12, 0xE000
cmplw r11, r12
blt pfEffectOriginal
lis r12, 0x470E
ori r12, r12, 0x9400
cmplw r11, r12
bgt pfEffectOriginal
lis r12, 0x46D0
ori r12, r12, 0x3400
cmplw r11, r12
blt pfAttachedLower
lis r12, 0x46F7
ori r12, r12, 0xDA00
cmplw r11, r12
blt pfAttachedMiddle
li r11, 3
b pfAttachedCompare
pfAttachedLower:
li r11, 1
b pfAttachedCompare
pfAttachedMiddle:
li r11, 2
pfAttachedCompare:
cmpw r11, r22
beq pfEffectOriginal
lis r12, pfAttachedState@ha
addi r12, r12, pfAttachedState@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
lwz r11, 4(r12)
add r11, r11, r7
stw r11, 4(r12)
; Skip only this colour draw; preserve the exact native attribute binding.
; The r8=0 feedback path already has its complete source bound.
cmpwi r8, 0
beq pfEffectDone
mr r5, r4
mr r4, r8
bl pfEffectBindNative
b pfEffectDone
pfAttachedMiss:

lwz r11, 0(r10)
cmpwi r11, 0
bne pfEffectOriginal
lwz r11, 4(r10)
lis r12, 0x80
cmpw r11, r12
bne pfEffectOriginal
lwz r11, 0x38(r10)
lwz r12, 0x2E8(r10)
cmplwi r11, 0xA27D
bne pfEffectCheckB
cmpwi r12, 152
bne pfEffectOriginal
b pfEffectIdentified
pfEffectCheckB:
cmplwi r11, 0xA283
bne pfEffectCheckC
cmpwi r12, 153
bne pfEffectOriginal
b pfEffectIdentified
pfEffectCheckC:
cmplwi r11, 0xA289
bne pfEffectOriginal
cmpwi r12, 154
bne pfEffectOriginal
pfEffectIdentified:
lis r12, pfState@ha
addi r12, r12, pfState@l
lwz r22, 8(r12)
cmplwi r22, 3
bgt pfEffectOriginal
; Plane zero means a regular world, where ALL bonus-plane glitter is foreign.
; Reject stale/unknown world state rather than infer a plane during loading.
lwz r11, 12(r12)
cmplwi r11, 1
blt pfEffectOriginal
cmplwi r11, 12
bgt pfEffectOriginal
mr r25, r8
cmpwi r25, 0
bne pfEffectHaveBuffer
mr r25, r27
pfEffectHaveBuffer:
lis r11, 0x1000
cmplw r25, r11
blt pfEffectOriginal
lis r11, 0x5000
cmplw r25, r11
bge pfEffectOriginal
cmpwi r7, 0
beq pfEffectOriginal
add r24, r6, r7
cmplw r24, r6
blt pfEffectOriginal
cmplwi r24, 8192
bgt pfEffectOriginal
mulli r11, r24, 192
add r11, r25, r11
lis r12, 0x5000
cmplw r11, r12
bgt pfEffectOriginal
mr r23, r6
li r26, -1
li r30, 0
lis r12, pfEffectFilterState@ha
addi r12, r12, pfEffectFilterState@l
lwz r11, 0(r12)
addi r11, r11, 1
stw r11, 0(r12)
pfEffectLoop:
cmplw r23, r24
bge pfEffectFlushEnd
cmpwi r22, 0
beq pfEffectReject
mulli r11, r23, 192
add r11, r25, r11
lwz r3, 4(r11)
mr r4, r22
bl pfEffectKeepY
cmpwi r3, 0
beq pfEffectReject
cmpwi r26, -1
bne pfEffectNext
mr r26, r23
b pfEffectNext
pfEffectReject:
addi r30, r30, 1
cmpwi r26, -1
beq pfEffectNext
bl pfEffectDrawRun
li r26, -1
pfEffectNext:
addi r23, r23, 1
b pfEffectLoop
pfEffectFlushEnd:
cmpwi r26, -1
beq pfEffectRebind
bl pfEffectDrawRun
pfEffectRebind:
; Restore the full binding even after rejecting every instance. Native GPU
; feedback uses it after the colour draw, so leave simulation unfiltered.
lwz r3, 8(r1)
mr r4, r25
lwz r5, 12(r1)
lwz r6, 20(r1)
lwz r7, 24(r1)
bl pfEffectBindNative
lis r12, pfEffectFilterState@ha
addi r12, r12, pfEffectFilterState@l
lwz r11, 4(r12)
add r11, r11, r30
stw r11, 4(r12)
b pfEffectDone
pfEffectOriginal:
lwz r3, 8(r1)
lwz r4, 12(r1)
lwz r5, 16(r1)
lwz r6, 20(r1)
lwz r7, 24(r1)
lwz r8, 28(r1)
lwz r9, 32(r1)
bl pfEffectNative
pfEffectDone:
lwz r20, 40(r1)
lwz r21, 44(r1)
lwz r22, 48(r1)
lwz r23, 52(r1)
lwz r24, 56(r1)
lwz r25, 60(r1)
lwz r26, 64(r1)
lwz r27, 68(r1)
lwz r28, 72(r1)
lwz r29, 76(r1)
lwz r30, 80(r1)
lwz r31, 84(r1)
lwz r0, 0xA4(r1)
mtlr r0
addi r1, r1, 0xA0
blr
; Same stack frame as caller: save only this leaf-helper return address.
pfEffectDrawRun:
mflr r0
stw r0, 92(r1)
lwz r3, 8(r1)
lwz r4, 12(r1)
lwz r5, 16(r1)
mr r6, r26
subf r7, r26, r23
mr r8, r25
lwz r9, 32(r1)
bl pfEffectNative
lis r12, pfEffectFilterState@ha
addi r12, r12, pfEffectFilterState@l
lwz r11, 8(r12)
addi r11, r11, 1
stw r11, 8(r12)
lwz r0, 92(r1)
mtlr r0
blr
; r3=IEEE local Y, r4=active plane. Return r3=1 for unknown or same plane.
pfEffectKeepY:
cmpwi r3, 0
bge pfEffectPositiveY
rlwinm r5, r3, 0, 1, 31
lis r6, 0x44FA
cmplw r5, r6
bgt pfEffectKeep
li r6, 1
b pfEffectComparePlane
pfEffectPositiveY:
lis r5, 0x463F
ori r5, r5, 0x6800
cmplw r3, r5
bgt pfEffectKeep
lis r5, 0x4516
ori r5, r5, 0x0000
cmplw r3, r5
blt pfEffectLowerY
lis r5, 0x45E9
ori r5, r5, 0x9800
cmplw r3, r5
blt pfEffectMiddleY
li r6, 3
b pfEffectComparePlane
pfEffectLowerY:
li r6, 1
b pfEffectComparePlane
pfEffectMiddleY:
li r6, 2
pfEffectComparePlane:
cmpw r6, r4
beq pfEffectKeep
li r3, 0
blr
pfEffectKeep:
li r3, 1
blr
pfAttachedState:
.int 0
.int 0
pfAttachedIdentities:
.int 0x00000000
.int 0x00000000
.int 0x0000D162
.int 0x00000000
.int 0x00000000
.int 0x0000D169
.int 0x00000000
.int 0x00800000
.int 0x00001FD4
.int 0x00000000
.int 0x00800000
.int 0x00001FDB
.int 0x00000000
.int 0x00801080
.int 0x00007F99
.int 0x00000000
.int 0x00800000
.int 0x00007FA5
.int 0x00000000
.int 0x00801880
.int 0x00007FAA
.int 0x00000001
.int 0x00060000
.int 0x0000CF43
.int 0x00000001
.int 0x00380000
.int 0x00002AC0
.int 0x00000000
.int 0x00380000
.int 0x00002AC5
.int 0x00000000
.int 0x00801800
.int 0x000012BD
.int 0x00000000
.int 0x00801880
.int 0x00006E49
.int 0x00000000
.int 0x00080200
.int 0x00006E4F
.int 0x00000000
.int 0x00801880
.int 0x00006E54
.int 0x00000000
.int 0x00801880
.int 0x00003FA3
.int 0x00000000
.int 0x00801880
.int 0x00008759

pfEffectFilterState:
.int 0
.int 0
.int 0
0x0253F478 = pfEffectNative:
0x02543ECC = pfEffectBindNative:
0x0253F8C4 = bla pfEffectSubmit
0x0253FA98 = bla pfEffectSubmit
0x0253FAB8 = bla pfEffectSubmit
0x0253FAF4 = bla pfEffectSubmit
0x023E3AD4 = bla pfDraw
