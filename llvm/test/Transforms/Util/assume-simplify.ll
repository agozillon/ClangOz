; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature
; RUN: opt -domtree -assumption-cache-tracker -assume-simplify -verify --enable-knowledge-retention -S %s | FileCheck %s
; RUN: opt -passes='require<domtree>,require<assumptions>,assume-simplify,verify' --enable-knowledge-retention -S %s | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @may_throw()
declare void @llvm.assume(i1)

define i32 @test1(i32* %0, i32* %1, i32 %2, i32 %3) {
; CHECK-LABEL: define {{[^@]+}}@test1
; CHECK-SAME: (i32* nonnull dereferenceable(4) [[TMP0:%.*]], i32* [[TMP1:%.*]], i32 [[TMP2:%.*]], i32 [[TMP3:%.*]])
; CHECK-NEXT:    [[TMP5:%.*]] = icmp ne i32 [[TMP2]], 4
; CHECK-NEXT:    br i1 [[TMP5]], label [[TMP6:%.*]], label [[A:%.*]]
; CHECK:       6:
; CHECK-NEXT:    [[TMP7:%.*]] = add nsw i32 [[TMP3]], [[TMP2]]
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32* [[TMP0]], i64 4), "align"(i32* [[TMP1]], i64 4), "nonnull"(i32* [[TMP1]]) ]
; CHECK-NEXT:    [[TMP8:%.*]] = load i32, i32* [[TMP0]], align 4
; CHECK-NEXT:    [[TMP9:%.*]] = add nsw i32 [[TMP7]], [[TMP8]]
; CHECK-NEXT:    store i32 0, i32* [[TMP0]], align 4
; CHECK-NEXT:    [[TMP10:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP11:%.*]] = add nsw i32 [[TMP9]], [[TMP10]]
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[TMP1]], i64 4), "ignore"(i32* undef) ]
; CHECK-NEXT:    store i32 [[TMP11]], i32* [[TMP1]], align 4
; CHECK-NEXT:    br label [[B:%.*]]
; CHECK:       A:
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32* [[TMP0]], i64 4), "ignore"(i32* undef, i64 4), "ignore"(i32* undef) ]
; CHECK-NEXT:    br label [[B]]
; CHECK:       B:
; CHECK-NEXT:    ret i32 0
;
  %5 = icmp ne i32 %2, 4
  call void @llvm.assume(i1 true) ["dereferenceable"(i32* %0, i64 4), "nonnull"(i32* %0) ]
  br i1 %5, label %6, label %A

6:                                                ; preds = %4
  %7 = add nsw i32 %3, %2
  call void @may_throw()
  %8 = load i32, i32* %0, align 4
  %9 = add nsw i32 %7, %8
  store i32 0, i32* %0, align 4
  call void @llvm.assume(i1 true) [ "align"(i32* %0, i64 4), "dereferenceable"(i32* %0, i64 4) ]
  %10 = load i32, i32* %1, align 4
  %11 = add nsw i32 %9, %10
  call void @llvm.assume(i1 true) [ "align"(i32* %1, i64 4), "nonnull"(i32* %1) ]
  call void @may_throw()
  call void @llvm.assume(i1 true) [ "dereferenceable"(i32* %1, i64 4), "nonnull"(i32* %1) ]
  store i32 %11, i32* %1, align 4
  br label %B

A:
  call void @llvm.assume(i1 true) [ "align"(i32* %0, i64 4), "dereferenceable"(i32* %0, i64 4), "nonnull"(i32* %0) ]
  br label %B

B:                                               ; preds = %6, %4
  ret i32 0
}

define i32 @test2(i32** %0, i32* %1, i32 %2, i32 %3) {
; CHECK-LABEL: define {{[^@]+}}@test2
; CHECK-SAME: (i32** [[TMP0:%.*]], i32* nonnull align 4 dereferenceable(4) [[TMP1:%.*]], i32 [[TMP2:%.*]], i32 [[TMP3:%.*]])
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, i32* [[TMP1]], i64 0
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, i32* [[TMP5]], align 4
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ne i32 [[TMP6]], 0
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i32, i32* [[TMP1]], i64 0
; CHECK-NEXT:    br i1 [[TMP7]], label [[TMP9:%.*]], label [[TMP19:%.*]]
; CHECK:       9:
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32* [[TMP8]], i64 4), "dereferenceable"(i32* [[TMP8]], i64 4), "nonnull"(i32* [[TMP8]]) ]
; CHECK-NEXT:    [[TMP10:%.*]] = load i32, i32* [[TMP8]], align 4
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds i32, i32* [[TMP1]], i64 2
; CHECK-NEXT:    store i32 [[TMP10]], i32* [[TMP11]], align 4
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    [[TMP12:%.*]] = getelementptr inbounds i32*, i32** [[TMP0]], i64 1
; CHECK-NEXT:    [[TMP13:%.*]] = load i32*, i32** [[TMP12]], align 8
; CHECK-NEXT:    [[TMP14:%.*]] = getelementptr inbounds i32, i32* [[TMP13]], i64 0
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[TMP1]], i64 12), "align"(i32* [[TMP13]], i64 4), "dereferenceable"(i32* [[TMP13]], i64 4), "nonnull"(i32* [[TMP13]]) ]
; CHECK-NEXT:    [[TMP15:%.*]] = load i32, i32* [[TMP14]], align 4
; CHECK-NEXT:    [[TMP16:%.*]] = getelementptr inbounds i32*, i32** [[TMP0]], i64 1
; CHECK-NEXT:    [[TMP17:%.*]] = load i32*, i32** [[TMP16]], align 8
; CHECK-NEXT:    [[TMP18:%.*]] = getelementptr inbounds i32, i32* [[TMP17]], i64 2
; CHECK-NEXT:    store i32 [[TMP15]], i32* [[TMP18]], align 4
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32** [[TMP0]], i64 4), "dereferenceable"(i32** [[TMP0]], i64 4), "nonnull"(i32** [[TMP0]]) ]
; CHECK-NEXT:    br label [[TMP35:%.*]]
; CHECK:       19:
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr inbounds i32*, i32** [[TMP0]], i64 7
; CHECK-NEXT:    [[TMP21:%.*]] = load i32*, i32** [[TMP20]], align 8
; CHECK-NEXT:    [[TMP22:%.*]] = getelementptr inbounds i32, i32* [[TMP21]], i64 0
; CHECK-NEXT:    [[TMP23:%.*]] = load i32, i32* [[TMP22]], align 4
; CHECK-NEXT:    [[TMP24:%.*]] = icmp ne i32 [[TMP23]], 0
; CHECK-NEXT:    br i1 [[TMP24]], label [[TMP25:%.*]], label [[TMP33:%.*]]
; CHECK:       25:
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32** [[TMP0]], i64 4), "dereferenceable"(i32** [[TMP0]], i64 4), "nonnull"(i32** [[TMP0]]) ]
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr inbounds i32*, i32** [[TMP0]], i64 2
; CHECK-NEXT:    [[TMP27:%.*]] = load i32*, i32** [[TMP26]], align 8
; CHECK-NEXT:    [[TMP28:%.*]] = getelementptr inbounds i32, i32* [[TMP27]], i64 0
; CHECK-NEXT:    [[TMP29:%.*]] = load i32, i32* [[TMP28]], align 4
; CHECK-NEXT:    [[TMP30:%.*]] = getelementptr inbounds i32*, i32** [[TMP0]], i64 2
; CHECK-NEXT:    [[TMP31:%.*]] = load i32*, i32** [[TMP30]], align 8
; CHECK-NEXT:    [[TMP32:%.*]] = getelementptr inbounds i32, i32* [[TMP31]], i64 2
; CHECK-NEXT:    store i32 [[TMP29]], i32* [[TMP32]], align 4
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    br label [[TMP33]]
; CHECK:       33:
; CHECK-NEXT:    br label [[TMP34:%.*]]
; CHECK:       34:
; CHECK-NEXT:    br label [[TMP35]]
; CHECK:       35:
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "align"(i32** [[TMP0]], i64 4), "dereferenceable"(i32** [[TMP0]], i64 4), "nonnull"(i32** [[TMP0]]) ]
; CHECK-NEXT:    ret i32 0
;
  %5 = getelementptr inbounds i32, i32* %1, i64 0
  %6 = load i32, i32* %5, align 4
  %7 = icmp ne i32 %6, 0
  call void @llvm.assume(i1 true) [ "align"(i32* %1, i64 4), "dereferenceable"(i32* %1, i64 4) ]
  call void @llvm.assume(i1 true) [ "align"(i32* %1, i64 4), "nonnull"(i32* %1) ]
  %8 = getelementptr inbounds i32, i32* %1, i64 0
  br i1 %7, label %9, label %19

9:                                                ; preds = %4
  call void @may_throw()
  call void @llvm.assume(i1 true) [ "align"(i32* %8, i64 4), "dereferenceable"(i32* %8, i64 4), "nonnull"(i32* %8) ]
  %10 = load i32, i32* %8, align 4
  %11 = getelementptr inbounds i32, i32* %1, i64 2
  store i32 %10, i32* %11, align 4
  call void @may_throw()
  call void @may_throw()
  call void @llvm.assume(i1 true) [ "align"(i32* %11, i64 4), "dereferenceable"(i32* %11, i64 4), "nonnull"(i32* %11) ]
  %12 = getelementptr inbounds i32*, i32** %0, i64 1
  %13 = load i32*, i32** %12, align 8
  %14 = getelementptr inbounds i32, i32* %13, i64 0
  %15 = load i32, i32* %14, align 4
  call void @llvm.assume(i1 true) [ "align"(i32* %14, i64 4), "dereferenceable"(i32* %14, i64 4), "nonnull"(i32* %14) ]
  %16 = getelementptr inbounds i32*, i32** %0, i64 1
  %17 = load i32*, i32** %16, align 8
  %18 = getelementptr inbounds i32, i32* %17, i64 2
  store i32 %15, i32* %18, align 4
  call void @may_throw()
  call void @llvm.assume(i1 true) [ "align"(i32** %0, i64 4), "dereferenceable"(i32** %0, i64 4), "nonnull"(i32** %0) ]
  br label %35

19:                                               ; preds = %4
  %20 = getelementptr inbounds i32*, i32** %0, i64 7
  %21 = load i32*, i32** %20, align 8
  %22 = getelementptr inbounds i32, i32* %21, i64 0
  %23 = load i32, i32* %22, align 4
  %24 = icmp ne i32 %23, 0
  br i1 %24, label %25, label %33

25:                                               ; preds = %19
  call void @may_throw()
  call void @llvm.assume(i1 true) [ "align"(i32** %0, i64 4), "dereferenceable"(i32** %0, i64 4), "nonnull"(i32** %0) ]
  %26 = getelementptr inbounds i32*, i32** %0, i64 2
  %27 = load i32*, i32** %26, align 8
  %28 = getelementptr inbounds i32, i32* %27, i64 0
  %29 = load i32, i32* %28, align 4
  %30 = getelementptr inbounds i32*, i32** %0, i64 2
  %31 = load i32*, i32** %30, align 8
  %32 = getelementptr inbounds i32, i32* %31, i64 2
  store i32 %29, i32* %32, align 4
  call void @may_throw()
  br label %33

33:                                               ; preds = %25, %19
  br label %34

34:                                               ; preds = %33
  br label %35

35:                                               ; preds = %34, %8
  call void @llvm.assume(i1 true) [ "align"(i32** %0, i64 4), "dereferenceable"(i32** %0, i64 4), "nonnull"(i32** %0) ]
  ret i32 0
}

define i32 @test3(i32* nonnull %p, i32 %i) {
; CHECK-LABEL: define {{[^@]+}}@test3
; CHECK-SAME: (i32* nonnull [[P:%.*]], i32 [[I:%.*]])
; CHECK-NEXT:    [[COND:%.*]] = icmp ne i32 [[I]], 0
; CHECK-NEXT:    br i1 [[COND]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       A:
; CHECK-NEXT:    ret i32 0
; CHECK:       B:
; CHECK-NEXT:    [[RET:%.*]] = load i32, i32* [[P]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  %cond = icmp ne i32 %i, 0
  call void @llvm.assume(i1 true) [ "nonnull"(i32* %p) ]
  br i1 %cond, label %A, label %B
A:
  ret i32 0
B:
  %ret = load i32, i32* %p
  ret i32 %ret
}

define i32 @test4(i32* %p, i32 %i) {
; CHECK-LABEL: define {{[^@]+}}@test4
; CHECK-SAME: (i32* nonnull dereferenceable(32) [[P:%.*]], i32 [[I:%.*]])
; CHECK-NEXT:    [[COND:%.*]] = icmp ne i32 [[I]], 0
; CHECK-NEXT:    br i1 [[COND]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       A:
; CHECK-NEXT:    ret i32 0
; CHECK:       B:
; CHECK-NEXT:    [[RET:%.*]] = load i32, i32* [[P]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  %cond = icmp ne i32 %i, 0
  call void @llvm.assume(i1 true) [ "nonnull"(i32* %p), "dereferenceable"(i32* %p, i32 32) ]
  br i1 %cond, label %A, label %B
A:
  ret i32 0
B:
  %ret = load i32, i32* %p
  ret i32 %ret
}

define i32 @test4A(i32* %p, i32 %i) {
; CHECK-LABEL: define {{[^@]+}}@test4A
; CHECK-SAME: (i32* [[P:%.*]], i32 [[I:%.*]])
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    [[COND:%.*]] = icmp ne i32 [[I]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "nonnull"(i32* [[P]]), "dereferenceable"(i32* [[P]], i32 32) ]
; CHECK-NEXT:    br i1 [[COND]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       A:
; CHECK-NEXT:    ret i32 0
; CHECK:       B:
; CHECK-NEXT:    [[RET:%.*]] = load i32, i32* [[P]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  call void @may_throw()
  %cond = icmp ne i32 %i, 0
  call void @llvm.assume(i1 true) [ "nonnull"(i32* %p), "dereferenceable"(i32* %p, i32 32) ]
  br i1 %cond, label %A, label %B
A:
  ret i32 0
B:
  %ret = load i32, i32* %p
  ret i32 %ret
}

define i32 @test5(i32* dereferenceable(64) %p, i32 %i) {
; CHECK-LABEL: define {{[^@]+}}@test5
; CHECK-SAME: (i32* nonnull dereferenceable(64) [[P:%.*]], i32 [[I:%.*]])
; CHECK-NEXT:    [[COND:%.*]] = icmp ne i32 [[I]], 0
; CHECK-NEXT:    br i1 [[COND]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       A:
; CHECK-NEXT:    ret i32 0
; CHECK:       B:
; CHECK-NEXT:    [[RET:%.*]] = load i32, i32* [[P]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  %cond = icmp ne i32 %i, 0
  call void @llvm.assume(i1 true) [ "nonnull"(i32* %p), "dereferenceable"(i32* %p, i32 32) ]
  br i1 %cond, label %A, label %B
A:
  ret i32 0
B:
  %ret = load i32, i32* %p
  ret i32 %ret
}


define i32 @test5A(i32* dereferenceable(8) %p, i32 %i) {
; CHECK-LABEL: define {{[^@]+}}@test5A
; CHECK-SAME: (i32* dereferenceable(32) [[P:%.*]], i32 [[I:%.*]])
; CHECK-NEXT:    [[COND:%.*]] = icmp ne i32 [[I]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "cold"(), "ignore"(i32* undef, i32 32) ]
; CHECK-NEXT:    br i1 [[COND]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       A:
; CHECK-NEXT:    ret i32 0
; CHECK:       B:
; CHECK-NEXT:    [[RET:%.*]] = load i32, i32* [[P]]
; CHECK-NEXT:    ret i32 [[RET]]
;
  %cond = icmp ne i32 %i, 0
  call void @llvm.assume(i1 true) [ "cold"(), "dereferenceable"(i32* %p, i32 32) ]
  br i1 %cond, label %A, label %B
A:
  ret i32 0
B:
  %ret = load i32, i32* %p
  ret i32 %ret
}

define i32 @test6() {
; CHECK-LABEL: define {{[^@]+}}@test6()
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "cold"() ]
; CHECK-NEXT:    call void @may_throw()
; CHECK-NEXT:    ret i32 0
;
  call void @llvm.assume(i1 true) [ "cold"() ]
  call void @llvm.assume(i1 true) [ "cold"() ]
  call void @may_throw()
  call void @llvm.assume(i1 true) [ "cold"() ]
  ret i32 0
}

define i32 @test7(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test7
; CHECK-SAME: (i32* align 4 dereferenceable(4) [[P:%.*]])
; CHECK-NEXT:    [[P1:%.*]] = bitcast i32* [[P]] to i8*
; CHECK-NEXT:    call void @llvm.assume(i1 true) [ "cold"(), "nonnull"(i32* [[P]]) ]
; CHECK-NEXT:    ret i32 0
;
  %p1 = bitcast i32* %p to i8*
  call void @llvm.assume(i1 true) [ "cold"() ]
  call void @llvm.assume(i1 true) [ "align"(i32* %p, i32 4) ]
  call void @llvm.assume(i1 true) [ "dereferenceable"(i32* %p, i32 4) ]
  call void @llvm.assume(i1 true) [ "align"(i8* %p1, i32 4), "nonnull"(i8* %p1) ]
  ret i32 0
}
