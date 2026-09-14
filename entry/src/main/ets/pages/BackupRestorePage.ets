import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { GlassCard } from '../common/components/GlassCard';

@Entry
@Component
struct BackupRestorePage {
  @State isDark: boolean = false;
  @State exportJsonString: string = '';
  @State importJsonString: string = '';
  @State activeTab: string = 'export'; // 'export' | 'import'

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    this.exportJsonString = StorageService.getInstance().exportDataAsJson();
  }

  private handleImport(): void {
    if (!this.importJsonString.trim()) {
      promptAction.showToast({ message: '请先粘贴待导入的 JSON 数据' });
      return;
    }

    const success = StorageService.getInstance().importDataFromJson(this.importJsonString);
    if (success) {
      promptAction.showToast({ message: '数据恢复成功！' });
      router.back();
    } else {
      promptAction.showToast({ message: 'JSON 格式解析失败，请检查数据完整性' });
    }
  }

  private handleReset(): void {
    StorageService.getInstance().resetToSampleData();
    promptAction.showToast({ message: '已重置为示范花草与日记数据' });
    router.back();
  }

  build() {
    Column() {
      // 1. 顶部 Header
      Row() {
        Button('❮ 返回')
          .fontSize(14)
          .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text('数据备份与恢复')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        Row()
          .width(52)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')

      Scroll() {
        Column({ space: 16 }) {
          // 2. 标签切换器
          Row({ space: 10 }) {
            Button('📦 导出与备份')
              .layoutWeight(1)
              .height(36)
              .fontSize(13)
              .fontWeight(this.activeTab === 'export' ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.activeTab === 'export' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
              .backgroundColor(
                this.activeTab === 'export'
                  ? (this.isDark ? '#B8985E' : '#C9A96E')
                  : (this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
              )
              .borderRadius(14)
              .onClick(() => {
                this.activeTab = 'export';
                this.exportJsonString = StorageService.getInstance().exportDataAsJson();
              })

            Button('📥 导入与恢复')
              .layoutWeight(1)
              .height(36)
              .fontSize(13)
              .fontWeight(this.activeTab === 'import' ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.activeTab === 'import' ? '#FFFFFF' : (this.isDark ? '#A29DC0' : '#6B6780'))
              .backgroundColor(
                this.activeTab === 'import'
                  ? (this.isDark ? '#B8985E' : '#C9A96E')
                  : (this.isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.04)')
              )
              .borderRadius(14)
              .onClick(() => {
                this.activeTab = 'import';
              })
          }
          .width('100%')

          if (this.activeTab === 'export') {
            // 导出视图
            GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
              Column({ space: 12 }) {
                Row({ space: 6 }) {
                  Text('💾')
                    .fontSize(16)
                  Text('全量沙盒数据 JSON')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
                }

                Text('包含花园花草、百花百科、养护打卡历史及成长手记。可全选复制保存至备忘录或文本文件中。')
                  .fontSize(12)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  .lineHeight(18)

                TextArea({ text: this.exportJsonString })
                  .fontSize(11)
                  .height(240)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .borderRadius(12)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          } else {
            // 导入视图
            GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 16 }) {
              Column({ space: 12 }) {
                Row({ space: 6 }) {
                  Text('📥')
                    .fontSize(16)
                  Text('粘贴待恢复数据 JSON')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
                }

                Text('请将此前导出的完整 JSON 文本粘贴于下方。导入后将完全恢复此前的所有数据并即时生效。')
                  .fontSize(12)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  .lineHeight(18)

                TextArea({ text: this.importJsonString, placeholder: '在此粘贴备份的 JSON 字符串...' })
                  .fontSize(11)
                  .height(200)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                  .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  .borderRadius(12)
                  .onChange((val: string) => {
                    this.importJsonString = val;
                  })

                Button('确认解析并导入恢复')
                  .width('100%')
                  .height(44)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .backgroundColor(this.isDark ? '#B8985E' : '#C9A96E')
                  .borderRadius(14)
                  .stateStyles({
                    pressed: {
                      .scale({ x: 0.97, y: 0.97 })
                      .opacity(0.88)
                    },
                    normal: {
                      .scale({ x: 1.0, y: 1.0 })
                      .opacity(1.0)
                    }
                  })
                  .animation({ duration: 150, curve: Curve.EaseOut })
                  .onClick(() => {
                    this.handleImport();
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 重置示范数据
            GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 16 }) {
              Column({ space: 10 }) {
                Text('↻ 恢复示范初始数据')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

                Text('若数据异常或想重新体验，可一键清空沙盒并重新灌入示范花木、日记与百科。')
                  .fontSize(12)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                  .lineHeight(18)

                Button('确认恢复示范数据')
                  .fontSize(13)
                  .fontColor('#E05252')
                  .backgroundColor(this.isDark ? 'rgba(224, 82, 82, 0.12)' : '#FDE8E8')
                  .borderRadius(12)
                  .height(36)
                  .width('100%')
                  .onClick(() => {
                    this.handleReset();
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }
        }
        .padding({ left: 16, right: 16, top: 14, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#100D1C' : '#FAF6F0')
  }

  pageTransition() {
    PageTransitionEnter({ duration: 280, curve: Curve.EaseInOut })
      .slide(SlideEffect.Right)
      .opacity(0)
    PageTransitionExit({ duration: 220, curve: Curve.EaseInOut })
      .slide(SlideEffect.Left)
      .opacity(0)
  }
}
