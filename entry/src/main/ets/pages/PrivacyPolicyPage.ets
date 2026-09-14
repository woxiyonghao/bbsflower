import router from '@ohos.router';
import { ThemeManager } from '../theme/ThemeManager';
import { GlassCard } from '../common/components/GlassCard';

@Entry
@Component
struct PrivacyPolicyPage {
  @State isDark: boolean = false;

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
  }

  onPageShow(): void {
    this.isDark = ThemeManager.getInstance().isDark();
  }

  build() {
    Column() {
      // 1. 顶部 Navigation Header
      Row() {
        Button('❮ 返回')
          .fontSize(14)
          .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text('隐私政策与用户协议')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        // 占位保持标题居中
        Row().width(50)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 2. 协议正文内容
      Scroll() {
        Column({ space: 14 }) {
          // 核心承诺亮点卡片
          GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 18 }) {
            Column({ space: 10 }) {
              Row({ space: 8 }) {
                Text('🛡️')
                  .fontSize(22)
                Text('纯单机离线承诺')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
              }

              Text('「琉璃花语」是一款完全单机运行的植物养护手记应用。我们严格遵循国家个人信息保护法及鸿蒙生态隐私合规标准，郑重向您承诺：')
                .fontSize(13)
                .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                .lineHeight(22)

              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text('🚫 无账号')
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  Text('无需手机号或注册')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                }
                .layoutWeight(1)

                Column({ space: 4 }) {
                  Text('🔒 零云端')
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  Text('数据仅存手机沙盒')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                }
                .layoutWeight(1)

                Column({ space: 4 }) {
                  Text('✨ 零广告')
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  Text('无跟踪与推广代码')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 6 })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 一、前言与主体说明
          GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
            Column({ space: 8 }) {
              Text('一、前言与主体说明')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              Text('本《隐私政策与用户协议》（以下简称“本政策”）适用于您通过移动设备使用「琉璃花语」（以下简称“本应用”）时所享有的权利与遵循的规范。本应用旨在为您提供私密、宁静的花木养护记录、四时农历打卡及百花图鉴查阅体验。')
                .fontSize(13)
                .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                .lineHeight(22)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 二、我们如何收集与使用您的信息
          GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
            Column({ space: 8 }) {
              Text('二、个人信息的收集与使用')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              Text('1. 不收集个人敏感信息：本应用不收集您的姓名、身份证号、手机号、地理位置、通讯录、短信、剪贴板等任何与植物养护无关的个人隐私数据。\n\n2. 不采集设备识别码：本应用不采集 IMEI、OAID、GAID、MAC 地址等设备唯一追踪标识符。\n\n3. 本地业务数据：您在应用内记录的花草爱称、浇水周期、生长度量、随笔心得等所有数据，均完全保存在您设备的私有沙盒存储区中，绝不向任何外部第三方服务器上传。')
                .fontSize(13)
                .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                .lineHeight(22)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 三、设备系统权限使用说明
          GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
            Column({ space: 8 }) {
              Text('三、设备系统权限使用说明')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              Text('1. 存储/媒体访问：当您主动为成长日记添加花草实拍照片时，应用会唤起鸿蒙系统的标准媒体选取组件供您单次选取指定相片。我们仅读取您授权的单张照片副本，绝不在后台扫描或窃取您的图库相册。\n\n2. 网络权限：本应用为纯单机架构，无联网依赖，不包含任何网络请求 SDK。\n\n3. 权限撤销：您可随时在系统「设置 - 应用与服务 - 权限管理」中撤销或调整相关权限授权。')
                .fontSize(13)
                .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                .lineHeight(22)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 四、数据存储、备份与权利行使
          GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
            Column({ space: 8 }) {
              Text('四、数据存储、备份与权利行使')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              Text('1. 自主备份：您可以在「雅舍 - 系统设置 - 数据备份与恢复」中随时将自己的全部养护数据导出为明文 JSON 文件保存至本地或个人存储设备。\n\n2. 一键清除：您可在设置中随时点击恢复示范数据或清除数据；当您从手机中卸载本应用时，鸿蒙系统将自动连带物理擦除本应用私有沙盒下的全部数据，不留存任何残留。')
                .fontSize(13)
                .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                .lineHeight(22)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }

          // 五、未成年人保护与条款变更
          GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
            Column({ space: 8 }) {
              Text('五、未成年人保护与政策更新')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

              Text('本应用高度重视未成年人的个人信息保护。因本应用不收集任何个人身份信息，未成年人可在监护人指导下放心使用本应用记录植物观察手记。\n\n若因版本升级导致本协议发生变更，我们将在版本更新说明或本页面中及时公布最新内容。\n\n生效日期：2026年9月14日\n开发者支持：winheo openharmony team')
                .fontSize(13)
                .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                .lineHeight(22)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 40 })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#1F1B2E' : '#F6F5F2')
  }

  pageTransition() {
    // 1. Push 进入当前页：从右边向左滑入
    PageTransitionEnter({ type: RouteType.Push, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
      .opacity(0)
    // 2. Pop 退出当前页返回上一级：向右边滑出
    PageTransitionExit({ type: RouteType.Pop, duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
      .opacity(0)
    // 3. 作为前置页面被更深级 Push 压栈时退出：向左边滑出
    PageTransitionExit({ type: RouteType.Push, duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
      .opacity(0)
    // 4. 更深级页面 Pop 返回时当前页面恢复：从左边滑入
    PageTransitionEnter({ type: RouteType.Pop, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Left)
      .opacity(0)
  }
}
