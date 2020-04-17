#include <iostream>
#include <thread>
#include <mutex>
#include <vector>
#include <stack>
#include <functional>
#include <atomic>
#include <condition_variable>
#include <memory>

// Heavily influenced by: https://vorbrodt.blog/2019/02/12/simple-thread-pool/ 
class ThreadPool {
      // if you want to have any kind of container for the thread_wrapper class 
      // then mutex/condition_variable have to be wrapped in a unique_ptr, a pool
      // of threads with seperate cv, mutex and booleans per thread would 
      // probably make this a non-issue

      size_t poolSize = std::thread::hardware_concurrency();

      std::unique_ptr<std::condition_variable> cv;
      
      std::unique_ptr<std::mutex> mutex;
      std::unique_ptr<std::atomic_bool> shutdown;

// need to make an atomic wrapper 
      std::vector<bool> noWork;
      std::vector<std::thread::id> threadIds;
      std::vector<std::thread> threads;

      std::stack<std::function<void(void)>> tasks;
//      queue<std::function<void(void)>> tasks;
      
    // 1) lock pops and pushes
    // 2) create a wait_till_empty/all takes done function with atomic bool
    // 3) Function that returns true if all threads are currently busy
    
     public:
     
      template <typename Func, typename ...Args>
      void enqueue_task(Func f, Args... args) {
        // is capture by value good enough? Reference is always risky though.
        std::lock_guard<std::mutex>(*mutex);
        tasks.push([=]() -> void { f(args...); });
      }
      
      ThreadPool() : mutex(std::make_unique<std::mutex>()),
                     shutdown(std::make_unique<std::atomic_bool>()) {
        
        for(size_t i = 0; i < poolSize; ++i) {
            noWork.push_back(false);
            threads.push_back(std::thread([this, index = i]() {
                while(true) {
                    std::lock_guard<std::mutex>(*mutex);
                    
                    // likely better to implement this with a condition variable
                    if (shutdown->load() == true) 
                      break;
                      
                    if (tasks.empty()) {
                      noWork[index] = true;
                      continue;
                    }
                    
                    tasks.top()();
                    tasks.pop();
                }
            }));
        
            threadIds.push_back(threads[i].get_id());
        }
      }
      
      ~ThreadPool() {
         shutdown->store(true);
         for (auto& thread : threads) {
            thread.join();
         }
      }
      
      ThreadPool(ThreadPool&&) = default;
      
      std::vector<std::thread::id> GetThreadIds() {
        return threadIds;
      }
      
      bool thread_has_work() {
        for (int i = 0; i < poolSize; ++i) {
          if (noWork[i] != true) {
            return true;
          
          }
        }
        
        return false;
      }
      
      // not quite correct, while the task list is empty it doesn't mean it's
      // ready to move on, the mutex may also be a good way to end up locking up
      // all the threads as this function may be called multiple times when 
      // nested
      bool wait_till_empty() {
//      std::lock_guard<std::mutex> lk(*mutex);
        while (1) { 
          if (!thread_has_work()) {
            break;
          }
        }
        
        return true;
      }
  };
  
  int main() {
 
    auto pool = ThreadPool();
    
    for (int i = 0; i < 4; ++i) {
      pool.enqueue_task([=](){ std::cout << i << "\n"; });
    }

//    pool.wait_till_empty();
    
    std::cout << "completed \n";
    
//    std::stack<std::function<void(void)>> tasks;
//    tasks.push([=]{});
//    if (tasks.top() == nullptr) {
//      std::cout << "Nullptr \n";
//    }
    
          


//     while(true) {
//          if (true)
//              continue;
//          
//     }
                
  
    return 0;
  }
  
  
