; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes --check-attributes
; RUN: opt -attributor -enable-new-pm=0 -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=8 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=8 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -enable-new-pm=0 -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

;; FIXME: support for extractvalue and insertvalue missing.

%0 = type { i32, i32 }

define internal %0 @foo(i1 %Q) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@foo
; IS__TUNIT____-SAME: (i1 [[Q:%.*]])
; IS__TUNIT____-NEXT:    br i1 [[Q]], label [[T:%.*]], label [[F:%.*]]
; IS__TUNIT____:       T:
; IS__TUNIT____-NEXT:    [[MRV:%.*]] = insertvalue [[TMP0:%.*]] undef, i32 21, 0
; IS__TUNIT____-NEXT:    [[MRV1:%.*]] = insertvalue [[TMP0]] [[MRV]], i32 22, 1
; IS__TUNIT____-NEXT:    ret [[TMP0]] [[MRV1]]
; IS__TUNIT____:       F:
; IS__TUNIT____-NEXT:    [[MRV2:%.*]] = insertvalue [[TMP0]] undef, i32 21, 0
; IS__TUNIT____-NEXT:    [[MRV3:%.*]] = insertvalue [[TMP0]] [[MRV2]], i32 23, 1
; IS__TUNIT____-NEXT:    ret [[TMP0]] [[MRV3]]
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@foo
; IS__CGSCC____-SAME: (i1 [[Q:%.*]])
; IS__CGSCC____-NEXT:    br i1 [[Q]], label [[T:%.*]], label [[F:%.*]]
; IS__CGSCC____:       T:
; IS__CGSCC____-NEXT:    [[MRV:%.*]] = insertvalue [[TMP0:%.*]] undef, i32 21, 0
; IS__CGSCC____-NEXT:    [[MRV1:%.*]] = insertvalue [[TMP0]] [[MRV]], i32 22, 1
; IS__CGSCC____-NEXT:    ret [[TMP0]] [[MRV1]]
; IS__CGSCC____:       F:
; IS__CGSCC____-NEXT:    [[MRV2:%.*]] = insertvalue [[TMP0]] undef, i32 21, 0
; IS__CGSCC____-NEXT:    [[MRV3:%.*]] = insertvalue [[TMP0]] [[MRV2]], i32 23, 1
; IS__CGSCC____-NEXT:    ret [[TMP0]] [[MRV3]]
;
  br i1 %Q, label %T, label %F

T:                                                ; preds = %0
  %mrv = insertvalue %0 undef, i32 21, 0
  %mrv1 = insertvalue %0 %mrv, i32 22, 1
  ret %0 %mrv1

F:                                                ; preds = %0
  %mrv2 = insertvalue %0 undef, i32 21, 0
  %mrv3 = insertvalue %0 %mrv2, i32 23, 1
  ret %0 %mrv3
}

define internal %0 @bar(i1 %Q) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@bar
; IS__TUNIT____-SAME: (i1 [[Q:%.*]])
; IS__TUNIT____-NEXT:    [[A:%.*]] = insertvalue [[TMP0:%.*]] undef, i32 21, 0
; IS__TUNIT____-NEXT:    br i1 [[Q]], label [[T:%.*]], label [[F:%.*]]
; IS__TUNIT____:       T:
; IS__TUNIT____-NEXT:    [[B:%.*]] = insertvalue [[TMP0]] [[A]], i32 22, 1
; IS__TUNIT____-NEXT:    ret [[TMP0]] [[B]]
; IS__TUNIT____:       F:
; IS__TUNIT____-NEXT:    [[C:%.*]] = insertvalue [[TMP0]] [[A]], i32 23, 1
; IS__TUNIT____-NEXT:    ret [[TMP0]] [[C]]
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@bar
; IS__CGSCC____-SAME: (i1 [[Q:%.*]])
; IS__CGSCC____-NEXT:    [[A:%.*]] = insertvalue [[TMP0:%.*]] undef, i32 21, 0
; IS__CGSCC____-NEXT:    br i1 [[Q]], label [[T:%.*]], label [[F:%.*]]
; IS__CGSCC____:       T:
; IS__CGSCC____-NEXT:    [[B:%.*]] = insertvalue [[TMP0]] [[A]], i32 22, 1
; IS__CGSCC____-NEXT:    ret [[TMP0]] [[B]]
; IS__CGSCC____:       F:
; IS__CGSCC____-NEXT:    [[C:%.*]] = insertvalue [[TMP0]] [[A]], i32 23, 1
; IS__CGSCC____-NEXT:    ret [[TMP0]] [[C]]
;
  %A = insertvalue %0 undef, i32 21, 0
  br i1 %Q, label %T, label %F

T:                                                ; preds = %0
  %B = insertvalue %0 %A, i32 22, 1
  ret %0 %B

F:                                                ; preds = %0
  %C = insertvalue %0 %A, i32 23, 1
  ret %0 %C
}

define %0 @caller(i1 %Q) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@caller
; IS__TUNIT____-SAME: (i1 [[Q:%.*]])
; IS__TUNIT____-NEXT:    [[X:%.*]] = call [[TMP0:%.*]] @foo(i1 [[Q]])
; IS__TUNIT____-NEXT:    ret [[TMP0]] [[X]]
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@caller
; IS__CGSCC____-SAME: (i1 [[Q:%.*]])
; IS__CGSCC____-NEXT:    [[X:%.*]] = call [[TMP0:%.*]] @foo(i1 [[Q]])
; IS__CGSCC____-NEXT:    ret [[TMP0]] [[X]]
;
  %X = call %0 @foo(i1 %Q)
  %A = extractvalue %0 %X, 0
  %B = extractvalue %0 %X, 1
  %Y = call %0 @bar(i1 %Q)
  %C = extractvalue %0 %Y, 0
  %D = extractvalue %0 %Y, 1
  %M = add i32 %A, %C
  %N = add i32 %B, %D
  ret %0 %X
}

; Similar to @caller but the result of both calls are actually used.
define i32 @caller2(i1 %Q) {
; IS__TUNIT____: Function Attrs: nofree nosync nounwind readnone willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@caller2
; IS__TUNIT____-SAME: (i1 [[Q:%.*]])
; IS__TUNIT____-NEXT:    [[X:%.*]] = call [[TMP0:%.*]] @foo(i1 [[Q]])
; IS__TUNIT____-NEXT:    [[A:%.*]] = extractvalue [[TMP0]] [[X]], 0
; IS__TUNIT____-NEXT:    [[B:%.*]] = extractvalue [[TMP0]] [[X]], 1
; IS__TUNIT____-NEXT:    [[Y:%.*]] = call [[TMP0]] @bar(i1 [[Q]])
; IS__TUNIT____-NEXT:    [[C:%.*]] = extractvalue [[TMP0]] [[Y]], 0
; IS__TUNIT____-NEXT:    [[D:%.*]] = extractvalue [[TMP0]] [[Y]], 1
; IS__TUNIT____-NEXT:    [[M:%.*]] = add i32 [[A]], [[C]]
; IS__TUNIT____-NEXT:    [[N:%.*]] = add i32 [[B]], [[D]]
; IS__TUNIT____-NEXT:    [[R:%.*]] = add i32 [[N]], [[M]]
; IS__TUNIT____-NEXT:    ret i32 [[R]]
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@caller2
; IS__CGSCC____-SAME: (i1 [[Q:%.*]])
; IS__CGSCC____-NEXT:    [[X:%.*]] = call [[TMP0:%.*]] @foo(i1 [[Q]])
; IS__CGSCC____-NEXT:    [[A:%.*]] = extractvalue [[TMP0]] [[X]], 0
; IS__CGSCC____-NEXT:    [[B:%.*]] = extractvalue [[TMP0]] [[X]], 1
; IS__CGSCC____-NEXT:    [[Y:%.*]] = call [[TMP0]] @bar(i1 [[Q]])
; IS__CGSCC____-NEXT:    [[C:%.*]] = extractvalue [[TMP0]] [[Y]], 0
; IS__CGSCC____-NEXT:    [[D:%.*]] = extractvalue [[TMP0]] [[Y]], 1
; IS__CGSCC____-NEXT:    [[M:%.*]] = add i32 [[A]], [[C]]
; IS__CGSCC____-NEXT:    [[N:%.*]] = add i32 [[B]], [[D]]
; IS__CGSCC____-NEXT:    [[R:%.*]] = add i32 [[N]], [[M]]
; IS__CGSCC____-NEXT:    ret i32 [[R]]
;
  %X = call %0 @foo(i1 %Q)
  %A = extractvalue %0 %X, 0
  %B = extractvalue %0 %X, 1
  %Y = call %0 @bar(i1 %Q)
  %C = extractvalue %0 %Y, 0
  %D = extractvalue %0 %Y, 1
  %M = add i32 %A, %C
;; Check that the second return values didn't get propagated
  %N = add i32 %B, %D
  %R = add i32 %N, %M
  ret i32 %R
}
