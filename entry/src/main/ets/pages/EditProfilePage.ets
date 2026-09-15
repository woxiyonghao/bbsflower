import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { UserProfileModel, PRESET_AVATARS } from '../common/models/UserProfileModel';
import { GlassCard } from '../common/components/GlassCard';

@Entry
@Component
struct EditProfilePage {
  @State isDark: boolean = false;
  @State avatar: string = '🌸';
  @State nickname: string = '';
  @State bio: string = '';

  private readonly PRESET_BIOS: string[] = [
    '一花一世界，一叶一菩提 · 单机绿意守护',
    '草木有本心，静守岁月长',
    '心有猛虎，细嗅蔷薇',
    '慢煮光阴一壶茶，静听花开一树春',
    '以琉璃为器，以花语为引'
  ];

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    const profile = StorageService.getInstance().getUserProfile();
    this.avatar = profile.avatar;
    this.nickname = profile.nickname;
    this.bio = profile.bio;
  }

  private handleSave(): void {
    const trimmedNickname = this.nickname.trim();
    if (!trimmedNickname) {
      try {
        promptAction.showToast({ message: '雅舍昵称不能为空' });
      } catch (e) {}
      return;
    }

    if (trimmedNickname.length > 16) {
      try {
        promptAction.showToast({ message: '昵称最多 16 个字' });
      } catch (e) {}
      return;
    }

    const trimmedBio = this.bio.trim();
    if (trimmedBio.length > 60) {
      try {
        promptAction.showToast({ message: '个人简介最多 60 个字' });
      } catch (e) {}
      return;
    }

    const profile: UserProfileModel = {
      avatar: this.avatar,
      nickname: trimmedNickname,
      bio: trimmedBio
    };

    StorageService.getInstance().saveUserProfile(profile);

    try {
      promptAction.showToast({ message: '雅舍资料保存成功' });
    } catch (e) {}

    router.back();
  }

  build() {
    Column() {
      // 1. 顶部 Header 导航栏
      Row() {
        Button('❮ 返回')
          .fontSize(14)
          .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

        Text('编辑雅舍资料')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 16 })

        Button('保存')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#1F1B33' : '#FFFFFF')
          .backgroundColor(this.isDark ? '#D4B87E' : '#C9A96E')
          .borderRadius(16)
          .height(32)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            this.handleSave();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.isDark ? 'rgba(28, 24, 42, 0.6)' : 'rgba(255, 255, 255, 0.8)')
      .backdropBlur(20)

      // 2. 主表单滚动区
      Scroll() {
        Column({ space: 16 }) {
          // 当前头像大卡片与选择器
          GlassCard({ isDark: this.isDark, radius: 24, paddingVal: 20 }) {
            Column({ space: 16 }) {
              Row() {
                Text('🏡 雅舍头像')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
                Blank()
                Text('点击下方图标切换')
                  .fontSize(12)
                  .fontColor(this.isDark ? '#8A85A4' : '#8E8AA3')
              }
              .width('100%')

              // 预览大头像
              Row() {
                Column() {
                  Text(this.avatar)
                    .fontSize(56)
                    .width(84)
                    .height(84)
                    .textAlign(TextAlign.Center)
                    .borderRadius(28)
                    .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.20)' : '#FDF2E2')
                    .border({
                      width: 2,
                      color: this.isDark ? '#D4B87E' : '#C9A96E'
                    })
                    .shadow({
                      radius: 12,
                      color: this.isDark ? 'rgba(212, 184, 126, 0.25)' : 'rgba(201, 169, 110, 0.25)',
                      offsetX: 0,
                      offsetY: 4
                    })

                  Text('当前头像')
                    .fontSize(11)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                    .margin({ top: 6 })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)

              // 预设头像网格
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
                ForEach(PRESET_AVATARS, (item: string) => {
                  Column() {
                    Text(item)
                      .fontSize(28)
                      .width(46)
                      .height(46)
                      .textAlign(TextAlign.Center)
                      .borderRadius(14)
                      .backgroundColor(
                        this.avatar === item
                          ? (this.isDark ? 'rgba(212, 184, 126, 0.35)' : '#FCE8CC')
                          : (this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                      )
                      .border({
                        width: this.avatar === item ? 2 : 1,
                        color: this.avatar === item
                          ? (this.isDark ? '#D4B87E' : '#C9A96E')
                          : (this.isDark ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.06)')
                      })
                  }
                  .margin({ bottom: 10 })
                  .onClick(() => {
                    this.avatar = item;
                  })
                }, (item: string) => item)
              }
              .width('100%')
            }
            .width('100%')
          }

          // 雅舍昵称编辑卡片
          GlassCard({ isDark: this.isDark, radius: 24, paddingVal: 20 }) {
            Column({ space: 10 }) {
              Row() {
                Text('🏷️ 雅舍昵称')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
                Blank()
                Text(`${this.nickname.length}/16`)
                  .fontSize(12)
                  .fontColor(this.isDark ? '#8A85A4' : '#8E8AA3')
              }
              .width('100%')

              TextInput({ text: this.nickname, placeholder: '为你的雅舍起一个雅致名称...' })
                .placeholderColor(this.isDark ? '#6B6780' : '#A29DC0')
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
                .fontSize(15)
                .maxLength(16)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .borderRadius(14)
                .height(46)
                .padding({ left: 14, right: 14 })
                .onChange((value: string) => {
                  this.nickname = value;
                })

              Text('展示在雅舍主页及日记签名处，支持 1~16 个字符。')
                .fontSize(11)
                .fontColor(this.isDark ? '#8A85A4' : '#8E8AA3')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          // 个人简介/心语编辑卡片
          GlassCard({ isDark: this.isDark, radius: 24, paddingVal: 20 }) {
            Column({ space: 10 }) {
              Row() {
                Text('📜 雅舍心语 / 个人简介')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
                Blank()
                Text(`${this.bio.length}/60`)
                  .fontSize(12)
                  .fontColor(this.isDark ? '#8A85A4' : '#8E8AA3')
              }
              .width('100%')

              TextArea({ text: this.bio, placeholder: '写下一句养花心语或座右铭...' })
                .placeholderColor(this.isDark ? '#6B6780' : '#A29DC0')
                .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
                .fontSize(14)
                .maxLength(60)
                .height(88)
                .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                .borderRadius(14)
                .padding(12)
                .onChange((value: string) => {
                  this.bio = value;
                })

              // 快速填入心语灵感
              Text('灵感参考（点击直接套用）：')
                .fontSize(12)
                .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                .margin({ top: 4 })

              Column({ space: 6 }) {
                ForEach(this.PRESET_BIOS, (preset: string) => {
                  Row() {
                    Text('🌸 ' + preset)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#DDD8EC' : '#4E4A62')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .borderRadius(8)
                  .backgroundColor(this.isDark ? 'rgba(255, 255, 255, 0.04)' : 'rgba(0, 0, 0, 0.03)')
                  .onClick(() => {
                    this.bio = preset;
                  })
                }, (preset: string) => preset)
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          // 底部保存大按钮
          Button('确认保存资料')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isDark ? '#1F1B33' : '#FFFFFF')
            .backgroundColor(this.isDark ? '#D4B87E' : '#C9A96E')
            .borderRadius(24)
            .shadow({
              radius: 12,
              color: this.isDark ? 'rgba(212, 184, 126, 0.3)' : 'rgba(201, 169, 110, 0.3)',
              offsetX: 0,
              offsetY: 4
            })
            .margin({ top: 8, bottom: 32 })
            .onClick(() => {
              this.handleSave();
            })
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#0F0D1A' : '#FBF7F2')
  }
}
