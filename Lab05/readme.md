### Lab05 實驗概述

使用 SRAM compiler 創 SRAM 來使用並且在特定的面積下完成 SPEC

### 實驗心得

1. 在使用 SRAM compiler 時會注意需要的面積與 SRAM 的形狀。
2. 和前面的 Lab04 相同一樣是做計算加速的硬體但這次需要注意的是面積的大小和 cycle time 的限制。因此這次需要切更深的 pipeline。
3. 在第一次合成時發現會合成超過 3 個小時但後來發現在使用 SRAM 時應為是 Hard IP，因此需要先引入 SRAM 的檔案後再合成可以將時間下降至 30 分鐘。
