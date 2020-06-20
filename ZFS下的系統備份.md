###### tags: `final project` `lsa` `ncnu`

# ZFS下的系統備份
本報告的目的：架設FreeNAS與ubuntu(root on zfs)，希望能夠達成利用zfs的功能來定期備分ubuntu系統，並且能夠遠端備份整個ubuntu以期之後若發生問題能夠快速將系統還原
## FreeNAS安裝與設定
```
這邊要介紹的是使用VirtualBox所安裝的FreeNAS，可以亂玩玩壞也沒關系。
其實就算裝在實體機器上也是差不多的步驟。
```
![](https://i.imgur.com/reFOLQb.png)
```
要注意的是FreeNAS的kernal是freeBSD，在設定虛擬機的的時候如果搞錯可能會打不開。
雖然圖上的記憶體設1G但是實際情況下最好要有8G
```
![](https://i.imgur.com/ziO7PVh.png)
```
然後設定一些虛擬硬碟，不然空空的NAS也沒東西可玩，然後把光碟映像檔放進去即可
```
![](https://i.imgur.com/G7wHTFO.png)
```
開機選號選項就能夠自動安裝～
```
![](https://i.imgur.com/vxCX1rf.png)
```
按照步驟做下去即可，很簡單
```
![](https://i.imgur.com/qp6vTCx.png)
![](https://i.imgur.com/HozGA0r.png)
![](https://i.imgur.com/WH5S5eJ.png)

![](https://i.imgur.com/ifgOWTG.png)
```
基本上都是直接用FreeNSA所提供web user interface系統進行操作
上面會提供網址，依照網址輸入即可
```
![](https://i.imgur.com/fz8ip32.png)
```
用剛剛設定的root來登入
```
![](https://i.imgur.com/LFgJiUA.png)
```
進去可以看到很多系統資訊
```
![](https://i.imgur.com/DaT6vlr.png)
```
直接開一個新的pool以利之後的備份
```
![](https://i.imgur.com/GXVVLh9.png)
```
設定好權限，就可以使用上面的各種功能來進行backup
```
![](https://i.imgur.com/tAvSo6h.png)
![](https://i.imgur.com/lysUwzT.png)
:::success
上面的null是我自己設的用戶，兵沒有其他意義喔
可以在`Accounts`新增自己的用戶組，設定自己的用戶
:::
```
基本上這邊就提供了很多功能
```
![](https://i.imgur.com/xM16AZ8.png)

### 在系統透過分散式檔案系統掛載NAS硬碟

```
這邊主要示範
windows下SMB掛載跟Ubuntu(Linux)底下NFS掛載
```
:::info
SMB跟NFS主要是設計來針對網路上的設備進行檔案傳輸的[分散式檔案系統](https://zh.wikipedia.org/wiki/%E5%88%86%E6%95%A3%E5%BC%8F%E6%AA%94%E6%A1%88%E7%B3%BB%E7%B5%B1)
:::
#### windowsのSMB篇
```
點這邊的相應的檔案系統(SMB)
```
![](https://i.imgur.com/k1DbsfX.png)
```
設定分享的名稱
```
![](https://i.imgur.com/ZHwRcoa.png)
```
在windows這邊要連結則是
因為要根據你的用戶組進行登入，所以"使用不同的認證"一定要勾選
```
![](https://i.imgur.com/VKtD1zP.png)

![](https://i.imgur.com/5mVjJki.png)
```
成功看到NAS的空間
```

![](https://i.imgur.com/8Z5k0ey.png)

#### LinuxのNFS篇
![](https://i.imgur.com/Mh3md1I.png)


```
跟windows不同的是，NFS等等要填入的不是分享名稱，而是分享的Database路徑
```
![](https://i.imgur.com/5sQd8lW.png)

```=shell
sudo apt install nfs-common #作為client端要安裝這個程式
sudo mkdir /mnt/NasShare  #創建一個掛載資料夾，NAS中test2的內容會出現在這個資料夾
```
![](https://i.imgur.com/YehOoBo.png)

```=shell
mount -t your_server:/mnt/Test2 
```
![](https://i.imgur.com/Z4gStzC.png)
```
如果此時在windows丟進一張相片
```
![](https://i.imgur.com/I5275wf.png)
```
在linux中也會同時出現
```
![](https://i.imgur.com/b0dzdps.png)

```
來Demo看看zfs系統下儲存檔案時同時會壓縮檔案，以更加不浪費磁碟的空間
```
![](https://i.imgur.com/zDdZhZj.png)
![](https://i.imgur.com/FR4N2NR.png)
![](https://i.imgur.com/XMlznYq.png)
![](https://i.imgur.com/l8lKI1J.png)
```
前後對比
```
![](https://i.imgur.com/NsVVdKM.png)

:::info
利用freeNAS+virtualbox，其實可以使用這種方法針對某些檔案進行區域網路的分享，跟zfs的snapshot功能，除此之外freeNAS上也有許多軟體應用可以串流影片跟相片
:::


## ubuntu Root on zfs
```
架設好zfs之後，我們還需要一台ubuntu的VM，一般的ubuntu可以安裝
```
一般的ubuntu機器可以透過

```
sudo apt install zfsutils-linux -y
```
來安裝zfs套件

**但是安裝完只能針對ubuntu系統以外的儲存空間做snapshot**

![](https://i.imgur.com/mSM0MN0.png)


如果要用zfs針對整個系統做備份是沒有辦法的。

所以就需要將root安裝在建好的zfs pool這樣才能做到完整的備份

以往的放法大多是在安裝好的ubuntu上裝好zfs，在將boot跟root轉移到新建的zfs pool，這邊就不細談了，有興趣可以看這篇文章：[Ubuntu Zoot on Zfs](https://openzfs.github.io/openzfs-docs/Getting%20Started/Ubuntu/Ubuntu%2018.04%20Root%20on%20ZFS.html#id9)

最新的Ubuntu20.04提供直接用zfs來安裝系統的選項
![](https://i.imgur.com/M9sZN7j.png)
```
甚至透過GRUB和ZSYS可以做到還原系統的功能
```
![](https://i.imgur.com/bLxNN2E.png)

![](https://i.imgur.com/6aOgHgB.png)

```
以後亂玩kernel也不用怕了(誤
```
不過備份都放在同一台機器上實在太危險，所以我們希望能夠透過zfs將整個root pool備份到遠端的機器，如FreeNAS，或是另一台ubuntu電腦
## 傳送備份到另一台機器上的ZFS
首先先說明，備份的方式：透過定期zfs的snapshot，在將這些snapshot傳送到遠端，在傳送時會將snapshot中所有的內容傳送過去，與一般備份系統不同的是，zfs send 與 receive 會在接收端重新建構一個相同的檔案架構，再傳送下一份snapshot的差異修和改了哪些部分仍然會保留。



以下會用兩台ubuntu20.04做說明:

首先要線設定好權限，為了省麻煩我們讓兩台交換rsa-key，也可以避免為了登入而在設定排程指令時將密碼明碼打出來。

再來就是對`recever`端的`backup pool`跟`sender`端需要備份的rpool進行權限調整

#### sender端
```=
zfs allow -u someuser send,snapshot mypool
```
#### receiver端
```=
sudo zfs create mypool/backup  #mypool是早已經創建好的pool
sudo zfs allow -u someuser create,mount,receive mypool/backup
sudo chown smoeuser /mypool/backup #更改owner
sudo chmod 777 /mypool/backup #這照自己需求
sudo chmod u+s /mypool/backup #給使用者在這個database有超級權限，讓使用者可以mount
sudo chmod g+s /mypool/backup
```

弄完結果　↓
![](https://i.imgur.com/9BH8uZL.png)
```
drwsrwsrwx 這樣就是上面的指令成功了
```

傳送指令:


```
sudo zfs send mypool@snapname | ssh user@server zsh recv -duv mypool@backup
```
`-d`:可覆寫在接收端使用相同名稱的快照
`-u`:可讓檔案系統在接收端不會被掛載
`-v`:會顯示更多有關傳輸的詳細資訊
sender端 成功傳送:
![](https://i.imgur.com/267Ikld.png)
* 註:再傳送時這個pool不能有其他人再使用 否則就會umount失敗

:::info
自己測試的時候，直接使用root來測試傳輸結果，再調整使用者權限會比較好
:::

參考:[ZFS send / receive non-root account](https://medium.com/@as.vignesh/zfs-send-receive-non-root-account-1978c284f8e2), [zfs 管理](https://www.freebsd.org/doc/zh_TW/books/handbook/zfs-zfs.html)

### 使用此方法差異備份
```=
sudo send -v -i mypool@snap1 mypool@snap2 | ssh user@server zsh recv -dvu mypool@backup
```
`-i` 另其比較兩個snapshot差異
![](https://i.imgur.com/0c0khsk.png)

![](https://i.imgur.com/h95XVTM.png)

### 在FreeNAS下此方法失效

因為ubuntu的原生檔案系統是ext4而非ZFS，為了相容性，在之前root-on-zfs中創建rpool我們會赴屬它許多的屬性，其中可能是dnode造成了傳輸時的問題。
:::info
dnode類似於ext之inode紀錄檔案系統各個block 
:::
在ubuntu下 當初創rpool時其中有一項`dnodesize=auto`這個會改變dnode的預設大小導致在send/recv時會出錯，在Freebsd底下創設之pool無法支援修改dnodesize
詳情請見[Open Feature Flags](https://openzfs.org/wiki/Feature_Flags)

會出現這行error
```
cannot receive: stream has unsupported feature, feature flags = 800004
```
相關訊息:[Breaking "zfs send" compatibility by activating the feature large_dnode on the rpool](https://github.com/ubuntu/zsys/issues/107)

## zfs-auto-snapshot
這是一個很好用的開源套件，安裝後會自動幫你完成crontab的設定，之後定期對每個pool進行快照備份。github上也有對其時區顯示錯誤問題做出修正的版本。
然而缺點是他還沒有支援zfs send 的功能，沒辦法實作遠端異地備份。

```
安裝說明

wget https://github.com/jasoncheng7115/zfs-auto-snapshot/archive/master.zip
unzip master.zip
cd zfs-auto-snapshot-master
make install
```

[zfs-auto-snapshot](https://github.com/jasoncheng7115/zfs-auto-snapshot)


## 設定crontab自動定期備份
預想是撰寫一個shell script可以在執行時自動完成快照+遠端備份，然後crontab自動排成的方式定期執行，達成定時自動備份的效果。

 ### shell script

```=shell
#!/bin/bash

backup_path="mypool"

snapshot_name=MEGA_OVER_POWER_$(date "+%Y-%m-%d-%H-%M-%S")

ssh_user="fstuba"

ssh_server="192.168.56.104"

backup_pool="backuppool/backup"


if [ -f "/etc/megaop/presnapname" ]; then
    pre_snapshot_name=$(cat /etc/megaop/presnapname)

    zfs snapshot ${backup_path}@${snapshot_name}

    zfs send -i ${backup_path}@${pre_snapshot_name} \
    ${backup_path}@${snapshot_name} | ssh ${ssh_user}@${ssh_server} \
    zfs recv ${backup_pool}@${snapshot_name} -F

    echo ${snapshot_name} > /etc/megaop/presnapname
else
    touch /etc/megaop/presnapname

    zfs snapshot ${backup_path}@${snapshot_name}
    zfs send ${backup_path}@${snapshot_name} | \
    ssh ${ssh_user}@${ssh_server} zfs recv ${backup_pool}@${snapshot_name} -F

    echo ${snapshot_name} > /etc/megaop/presnapname
fi
```
:::info
記得script檔需要給他可執行的權限：
>chmod +x megaop.sh

這個script需要放置在/etc/megaop/ 目錄中，執行時會偵測資料夾內有沒有presnapname檔案，沒有的話會自動生成，用以紀錄增量備份的前後檔案關聯。
:::


### crontab設定檔

```
# /etc/cron.d/magaop: crontab setting for megaop.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

* * * * *   root	/etc/megaop/megaop.sh
```
:::info
放置於/etc/cron.d/ 目錄中，crontab在運行時會掃描這個目錄並根據設定檔進行自動排程。
:::

![](https://i.imgur.com/Dx7QFt1.png)
