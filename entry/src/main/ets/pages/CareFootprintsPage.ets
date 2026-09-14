import router from '@ohos.router';
import { CareLogModel } from '../common/models/CareLogModel';
import { StorageService } from '../common/database/StorageService';
import { ThemeManager } from '../theme/ThemeManager';
import { GlassCard } from '../common/components/GlassCard';

/**
 * 按日期分组的养护足迹数据结构
 */
interface DateCareGroup {
  date: string;       // yyyy-mm-dd
  weekday: string;    // 星期/周
  logs: CareLogModel[];
}

interface FilterOption {
  key: string;
  name: string;
  icon: string;
}

@Entry
@Component
struct CareFootprintsPage {
  @State isDark: boolean = false;
  @State careLogs: CareLogModel[] = [];
  @State selectedFilter: string = 'all';

  private readonly FILTERS: FilterOption[] = [
    { key: 'all', name: '全部', icon: '🌱' },
    { key: 'water', name: '浇水', icon: '💧' },
    { key: 'fertilize', name: '施肥', icon: '🌿' },
    { key: 'mist', name: '喷雾', icon: '💨' },
    { key: 'prune', name: '修剪', icon: '✂️' }
  ];

  aboutToAppear(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    this.loadData();
  }

  onPageShow(): void {
    this.isDark = ThemeManager.getInstance().isDark();
    this.loadData();
  }

  private loadData(): void {
    this.careLogs = StorageService.getInstance().getCareLogs();
  }

  /**
   * 提取不同动作对应的 emoji 图标
   */
  private getActionIcon(actionType: string): string {
    switch (actionType) {
      case 'water': return '💧';
      case 'fertilize': return '🌿';
      case 'mist': return '💨';
      case 'prune': return '✂️';
      case 'repot': return '🪴';
      default: return '🌱';
    }
  }

  /**
   * 计算不重复的养护天数
   */
  private getUniqueDaysCount(): number {
    const dates = new Set<string>();
    for (let i = 0; i < this.careLogs.length; i++) {
      if (this.careLogs[i].date) {
        dates.add(this.careLogs[i].date);
      }
    }
    return dates.size;
  }

  /**
   * 获取按 yyyy-mm-dd 分组并降序排列的养护足迹列表
   */
  private getGroupedCareLogs(): DateCareGroup[] {
    // 1. 过滤
    let filtered = this.careLogs;
    if (this.selectedFilter !== 'all') {
      filtered = this.careLogs.filter(l => l.actionType === this.selectedFilter);
    }

    // 2. 排序（日期倒序，时间倒序）
    const sorted = [...filtered].sort((a, b) => {
      const cmp = b.date.localeCompare(a.date);
      if (cmp !== 0) {
        return cmp;
      }
      return (b.time || '').localeCompare(a.time || '');
    });

    // 3. 按 yyyy-mm-dd 分组
    const groupMap: Map<string, CareLogModel[]> = new Map();
    for (let i = 0; i < sorted.length; i++) {
      const log = sorted[i];
      const dateKey = log.date || '未知日期';
      if (!groupMap.has(dateKey)) {
        groupMap.set(dateKey, []);
      }
      groupMap.get(dateKey)!.push(log);
    }

    // 4. 组装结果
    const groups: DateCareGroup[] = [];
    groupMap.forEach((logs, date) => {
      let weekday = '';
      try {
        const parts = date.split('-');
        if (parts.length === 3) {
          const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
          const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
          weekday = weekDays[d.getDay()];
        }
      } catch (e) {
        weekday = '';
      }

      groups.push({
        date,
        weekday,
        logs
      });
    });

    return groups;
  }

  build() {
    Column() {
      // 1. 顶部 Navigation Bar
      Stack({ alignContent: Alignment.Center }) {
        Text('全部足迹')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDark ? '#F2EFF9' : '#1F1B33')
          .textAlign(TextAlign.Center)

        Row() {
          Button('❮ 返回')
            .fontSize(14)
            .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
            .backgroundColor('transparent')
            .onClick(() => {
              router.back();
            })

          Blank()

          Button('＋ 补记')
            .fontSize(13)
            .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
            .backgroundColor('transparent')
            .onClick(() => {
              router.pushUrl({ url: 'pages/RetrofitCarePage' });
            })
        }
        .width('100%')
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')

      // 2. 主列表区域
      Scroll() {
        Column({ space: 14 }) {
          // 概览统计卡片
          GlassCard({ isDark: this.isDark, radius: 18, paddingVal: 14 }) {
            Row() {
              Column({ space: 4 }) {
                Text(`${this.careLogs.length}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#D4B87E' : '#C9A96E')
                Text('累计足迹')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Divider()
                .vertical(true)
                .height(30)
                .color(this.isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.06)')

              Column({ space: 4 }) {
                Text(`${this.getUniqueDaysCount()}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#8EE0D0' : '#388E6D')
                Text('陪伴天数')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Divider()
                .vertical(true)
                .height(30)
                .color(this.isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.06)')

              Column({ space: 4 }) {
                Text(`${this.careLogs.filter(l => l.actionType === 'water').length}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isDark ? '#9CC8F0' : '#2B6CB0')
                Text('浇灌甘霖')
                  .fontSize(11)
                  .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
          }

          // 动作分类筛选胶囊（全屏等宽自适应布局，不截断不换行）
          Row({ space: 6 }) {
            ForEach(this.FILTERS, (filter: FilterOption) => {
              Row({ space: 3 }) {
                Text(filter.icon)
                  .fontSize(11)
                Text(filter.name)
                  .fontSize(11.5)
                  .fontWeight(this.selectedFilter === filter.key ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(
                    this.selectedFilter === filter.key
                      ? (this.isDark ? '#140E24' : '#FFFFFF')
                      : (this.isDark ? '#A29DC0' : '#6B6780')
                  )
              }
              .layoutWeight(1)
              .height(32)
              .justifyContent(FlexAlign.Center)
              .borderRadius(14)
              .backgroundColor(
                this.selectedFilter === filter.key
                  ? (this.isDark ? '#D4B87E' : '#A8874A')
                  : (this.isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)')
              )
              .onClick(() => {
                this.selectedFilter = filter.key;
              })
            })
          }
          .width('100%')

          // 分组表格列表
          if (this.getGroupedCareLogs().length === 0) {
            // 空状态
            Column({ space: 10 }) {
              Text('🍃')
                .fontSize(40)
              Text('暂无养护足迹记录')
                .fontSize(14)
                .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
            }
            .width('100%')
            .padding({ top: 60, bottom: 60 })
            .alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.getGroupedCareLogs(), (group: DateCareGroup) => {
              Column({ space: 6 }) {
                // 以 yyyy-mm-dd 为组头 (Section Header)
                Row() {
                  Row({ space: 6 }) {
                    Text('📅')
                      .fontSize(12)
                    Text(group.date)
                      .fontSize(13.5)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isDark ? '#E5E2EE' : '#2D2A3F')
                    if (group.weekday.length > 0) {
                      Text(group.weekday)
                        .fontSize(11)
                        .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                    }
                  }
                  .alignItems(VerticalAlign.Center)

                  Blank()

                  Text(`${group.logs.length} 次养护`)
                    .fontSize(11)
                    .fontColor(this.isDark ? '#D4B87E' : '#A8874A')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .backgroundColor(this.isDark ? 'rgba(212, 184, 126, 0.12)' : 'rgba(201, 169, 110, 0.12)')
                    .borderRadius(8)
                }
                .width('100%')
                .padding({ left: 4, right: 4, top: 4 })

                // 组内表格卡片 (Table Body)
                GlassCard({ isDark: this.isDark, radius: 16, paddingVal: 0 }) {
                  Column() {
                    ForEach(group.logs, (log: CareLogModel, idx: number) => {
                      Row({ space: 10 }) {
                        Text(this.getActionIcon(log.actionType))
                          .fontSize(18)

                        Column({ space: 3 }) {
                          Text(`为「${log.plantName}」完成${log.actionName}`)
                            .fontSize(13)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(this.isDark ? '#F2EFF9' : '#2D2A3F')

                          if (log.note && log.note.length > 0) {
                            Text(log.note)
                              .fontSize(11)
                              .fontColor(this.isDark ? '#A29DC0' : '#8E8AA3')
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)

                        Row({ space: 4 }) {
                          Text(log.time)
                            .fontSize(11)
                            .fontColor(this.isDark ? '#736F90' : '#8E8AA3')
                          Text('›')
                            .fontSize(14)
                            .fontColor(this.isDark ? '#534F70' : '#C0BCD0')
                        }
                        .alignItems(VerticalAlign.Center)
                      }
                      .width('100%')
                      .padding({ left: 14, right: 14, top: 11, bottom: 11 })
                      .borderWidth(idx < group.logs.length - 1 ? { bottom: 1 } : { bottom: 0 })
                      .borderColor(this.isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.04)')
                      .onClick(() => {
                        if (log.plantId) {
                          router.pushUrl({
                            url: 'pages/PlantDetailPage',
                            params: { plantId: log.plantId }
                          });
                        }
                      })
                    })
                  }
                  .width('100%')
                  .clip(true)
                  .borderRadius(16)
                }
              }
              .width('100%')
            })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 40 })
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDark ? '#140E24' : '#F9F5EE')
  }

  pageTransition() {
    // 1. Push 打开当前页：从右边滑入
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
