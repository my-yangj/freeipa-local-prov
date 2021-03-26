# utils
here are a few scripts to perform system maintainess,

## backup
- duplicity & deja back vs. zfs for incremental backup. 
  - duplicity is easier to setup and use, it is integrated with ubuntu desktop and the file manager menu support restoring to previous version. 
  - zfs can diff fs snapshot and generate delta based on COW, i guess it operats at block level thus if one intermediate snapshot corrupted, all incremental backup after it will lost.
  - zfs snapshot and delta is fast. duplicity will scan the data for each backup, i am not sure how long it will take after I have hundreds GB.
  
  deja is selected!
  
