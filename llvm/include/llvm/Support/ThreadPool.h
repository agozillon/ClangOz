//===-- llvm/Support/ThreadPool.h - A ThreadPool implementation -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines a crude C++11 based thread pool.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_THREAD_POOL_H
#define LLVM_SUPPORT_THREAD_POOL_H

#include "llvm/Config/llvm-config.h"
#include "llvm/Support/thread.h"

#include <future>

#include <atomic>
#include <condition_variable>
#include <functional>
#include <memory>
#include <mutex>
#include <queue>
#include <utility>

namespace llvm {

/// A ThreadPool for asynchronous parallel execution on a defined number of
/// threads.
///
/// The pool keeps a vector of threads alive, waiting on a condition variable
/// for some work to become available.
class ThreadPool {
public:
  using TaskTy = std::function<void()>;
  using PackagedTaskTy = std::packaged_task<void()>;

  /// Construct a pool with the number of threads found by
  /// hardware_concurrency().
  ThreadPool();

  /// Construct a pool of \p ThreadCount threads
  ThreadPool(unsigned ThreadCount);

  /// Blocking destructor: the pool will wait for all the threads to complete.
  ~ThreadPool();

  /// Asynchronous submission of a task to the pool. The returned future can be
  /// used to wait for the task to finish and is *non-blocking* on destruction.
  template <typename Function, typename... Args>
  inline std::shared_future<void> async(Function &&F, Args &&... ArgList) {
    auto Task =
        std::bind(std::forward<Function>(F), std::forward<Args>(ArgList)...);
    return asyncImpl(std::move(Task));
  }

  /// Asynchronous submission of a task to the pool. The returned future can be
  /// used to wait for the task to finish and is *non-blocking* on destruction.
  template <typename Function>
  inline std::shared_future<void> async(Function &&F) {
    return asyncImpl(std::forward<Function>(F));
  }

  /// Returns vector containing native thread identifiers for each thread in the
  /// pool
  inline std::vector<std::thread::id> getThreadIds() {
    return ThreadIds;
  }
  
  inline size_t getPoolSize() {
    return Threads.size();
  }
  
  inline bool threadsAreActive() { return (ActiveThreads > 0); };
  
  /// Blocking wait for all the threads to complete and the queue to be empty.
  /// It is an error to try to add new tasks while blocking on this call.
  void wait();

private:
  /// Asynchronous submission of a task to the pool. The returned future can be
  /// used to wait for the task to finish and is *non-blocking* on destruction.
  std::shared_future<void> asyncImpl(TaskTy F);

  /// Threads in flight
  std::vector<llvm::thread> Threads;
  
  /// Native identifiers for each thread in flight
  std::vector<std::thread::id> ThreadIds;
  
  /// Tasks waiting for execution in the pool.
  std::queue<PackagedTaskTy> Tasks;

  /// Locking and signaling for accessing the Tasks queue.
  std::mutex QueueLock;
  std::condition_variable QueueCondition;

  /// Locking and signaling for job completion
  std::mutex CompletionLock;
  std::condition_variable CompletionCondition;

  /// Keep track of the number of thread actually busy
  std::atomic<unsigned> ActiveThreads;

#if LLVM_ENABLE_THREADS // avoids warning for unused variable
  /// Signal for the destruction of the pool, asking thread to exit.
  bool EnableFlag;
#endif
};
}

#endif // LLVM_SUPPORT_THREAD_POOL_H
