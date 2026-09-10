LING V10｜會員序號正式版設定

這一版已經拿掉「關於我、銷售介紹、售價、LINE 購買」等內容。
APP 只保留會員登入＋完整品牌工具。

下一階段已加入：
• 每位客人一組獨立序號
• 第一次登入自動綁定該裝置
• 同一序號不能直接拿去另一台裝置使用
• 可在 Supabase 將序號設成 revoked 停權
• 可解除裝置綁定，讓客人換手機
• 每次重新開啟 APP 都會向資料庫確認序號仍有效

啟用步驟：
1. 免費建立一個 Supabase 專案。
2. 開啟 SQL Editor，把 SUPABASE-SETUP.sql 全部貼上執行。
3. 到 Project Settings / API，複製 Project URL 與 anon public key。
4. 打開 config.js，把兩個 PASTE... 欄位換成你的資料。
5. 把本資料夾全部上傳到你的 ling-brand-tool GitHub repo。

發序號：
到 Supabase 的 Table Editor > ling_licenses，新建一列，只需填 code，例如 LING-899-B001，status 保持 active。

停權：
把該列 status 改成 revoked。

換裝置：
把該客人的 device_id 清空；客人在新裝置再次輸入序號後會重新綁定。

提醒：
Supabase 的 anon key 本來就允許放前端；真正的資料表權限由 RLS + security definer RPC 控制。
請不要把 Supabase service_role key 放進 config.js。
