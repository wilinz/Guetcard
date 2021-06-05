- [ ] 安卓端更新检测和应用内更新功能
- [ ] iOS 端更新检测和跳转 Gitee 更新功能
- [ ] 忽略更新功能：今天不再提醒我（将当前日期存入 SharedPreferences 的 ignoreUpdateDate 中
- [ ] 忽略更新功能：忽略此版本（将忽略的版本号存入 SharedPreferences 的 ignoreUpdateVersion 中
- [ ] 应用启动时判断 ignoreUpdateDate 是否是过去的时间，如果是的话则删除值
- [ ] 应用启动时判断 ignoreUpdateVersion 是否为当前版本，如果是的话则删除值
- [ ] 前两个判断完成之后判断是否存在 ignoreUpdateDate，若不存在则调用更新检测，
      如果检测到的版本与 ignoreUpdateVersion 不相同，或 ignoreUpdateVersion 为 null，
      则弹窗提示是否更新。 