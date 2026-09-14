import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DiaryModel } from '../common/models/DiaryModel';
import { PlantModel } from '../common/models/PlantModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { GlassCard } from '../common/components/GlassCard';
import { StatBadge } from '../common/components/StatBadge';
import { PlantIcon } from '../common/components/PlantIcon';

interface DiaryDetailParams {
  diaryId: string;
}

@Entry
@Component
struct DiaryDetailPage {
  @State isDark: boolean = false;
  @State diaryId: string = '';
  @State diary: DiaryModel | null = null;
  @State plant: PlantModel | null = null;

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    const params = router.getParams() as DiaryDetailParams;
    if (params && params.diaryId) {
      this.diaryId = params.diaryId;
    }
    this.loadData();
  }

  onPageShow(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    this.loadData();
  }

  private loadData(): void {
    const storage = StorageService.getInstance();
    if (this.diaryId) {
      const d = storage.getDiaryById(this.diaryId);
      if (d) {
        this.diary = d;
        if (d.plantId) {
          this.plant = storage.getPlantById(d.plantId) || null;
        }
      }
    }
  }

  private deleteDiary(): void {
    if (!this.diary) {
      return;
    }
    promptAction.showDialog({
      title: '删除成长日记',
      message: '确定要删除这篇成长记录吗？删除后不可恢复。',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确定删除', color: '#E05353' }
      ]
    }).then((result) => {
      if (result.index === 1 && this.diary) {
        StorageService.getInstance().deleteDiary(this.diary.id);
        promptAction.showToast({ message: '日记已删除', duration: 1500 });
        setTimeout(() => {
          router.back();
        }, 300);
      }
    }).catch(() => {});
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

        Text('日记详情')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')

        Blank()

        Row({ space: 8 }) {
          Button('编辑')
            .fontSize(13)
            .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
            .backgroundColor('transparent')
            .onClick(() => {
              if (this.diary) {
                router.pushUrl({
                  url: 'pages/AddDiaryPage',
                  params: { diaryId: this.diary.id }
                });
              }
            })

          Button('删除')
            .fontSize(13)
            .fontColor('#E05252')
            .backgroundColor('transparent')
            .onClick(() => {
              this.deleteDiary();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 2. 页面内容
      Scroll() {
        Column({ space: 14 }) {
          if (this.diary) {
            // 日记主信息卡片
            GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 18 }) {
              Column({ space: 12 }) {
                // 标题与心情、标签
                Row() {
                  Row({ space: 8 }) {
                    Text(this.diary.mood)
                      .fontSize(24)
                    Text(this.diary.title)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                  }

                  Blank()

                  StatBadge({
                    text: this.diary.tagName,
                    colorScheme: 'petal',
                    isDark: this.isDark
                  })
                }
                .width('100%')

                // 记录时间与归属
                Row({ space: 8 }) {
                  Text(`📅 ${this.diary.date} ${this.diary.time}`)
                    .fontSize(12)
                    .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')

                  if (this.diary.plantName) {
                    Text('·')
                      .fontSize(12)
                      .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                    Text(`🪴 归属: ${this.diary.plantName}`)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                  }
                }
                .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 关联的植物卡片（可点击跳转至植物档案）
            if (this.plant) {
              GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 14 }) {
                Row({ space: 12 }) {
                  PlantIcon({
                    plantName: this.plant.name,
                    sizeVal: 46,
                    isDark: this.isDark
                  })

                  Column({ space: 3 }) {
                    Row({ space: 6 }) {
                      Text(this.plant.nickname)
                        .fontSize(15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')
                      Text(`(${this.plant.name})`)
                        .fontSize(12)
                        .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                    }

                    Text(`摆放位置: ${this.plant.location} · 查看专属植物档案 →`)
                      .fontSize(12)
                      .fontColor(this.isDark ? '#7BC4A8' : '#3B8256')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .onClick(() => {
                  if (this.plant) {
                    router.pushUrl({
                      url: 'pages/PlantDetailPage',
                      params: { plantId: this.plant.id }
                    });
                  }
                })
              }
            }

            // 日记文字心得
            GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 18 }) {
              Column({ space: 10 }) {
                Text('🌱 记录心得与观察')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

                Text(this.diary.content || '暂无详细心得文字')
                  .fontSize(14)
                  .fontColor(this.isDark ? '#DCD8EA' : '#4E4A62')
                  .lineHeight(24)
                  .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }

            // 照片展示
            if (this.diary.imageUri && this.diary.imageUri.length > 0) {
              GlassCard({ isDark: this.isDark, radius: 20, paddingVal: 14 }) {
                Column({ space: 8 }) {
                  Text('📷 成长相册记录')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')

                  Image(this.diary.imageUri)
                    .width('100%')
                    .height(220)
                    .borderRadius(14)
                    .objectFit(ImageFit.Cover)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
            }
          } else {
            Column({ space: 12 }) {
              Text('🌱')
                .fontSize(44)
              Text('日记不存在或已被删除')
                .fontSize(14)
                .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
            }
            .width('100%')
            .padding(40)
            .justifyContent(FlexAlign.Center)
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
    PageTransitionEnter({ type: RouteType.Push, duration: 280, curve: Curve.EaseOut })
      .slide(SlideEffect.Left).opacity(0.8)
    PageTransitionExit({ type: RouteType.Pop, duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right).opacity(0.8)
    PageTransitionEnter({ type: RouteType.Pop, duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right).opacity(0.8)
    PageTransitionExit({ type: RouteType.Push, duration: 280, curve: Curve.EaseIn })
      .slide(SlideEffect.Left).opacity(0.8)
  }
}
