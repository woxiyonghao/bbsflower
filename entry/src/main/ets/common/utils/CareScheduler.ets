import { PlantModel } from '../models/PlantModel';
import { DateUtil } from './DateUtil';

export interface CareTaskItem {
  plantId: string;
  plantName: string;
  nickname: string;
  location: string;
  icon: string;
  actionType: string;       // water / fertilize
  actionName: string;       // 浇水 / 施肥
  dueDate: string;          // 建议日期
  diffDays: number;         // 相对于今日的差值：负数代表逾期，0代表今日，正数代表未来
  statusDesc: string;       // 状态文字：如 "已逾期 2 天"、"今日待办"
  isOverdue: boolean;       // 是否逾期
}

export class CareScheduler {
  /**
   * 计算下次建议浇水日期
   */
  public static getNextWaterDate(plant: PlantModel): string {
    if (!plant.lastWaterDate) {
      return DateUtil.formatDate();
    }
    return DateUtil.addDays(plant.lastWaterDate, plant.waterInterval);
  }

  /**
   * 计算下次建议施肥日期
   */
  public static getNextFertilizeDate(plant: PlantModel): string {
    if (!plant.lastFertilizeDate) {
      return DateUtil.formatDate();
    }
    return DateUtil.addDays(plant.lastFertilizeDate, plant.fertilizeInterval);
  }

  /**
   * 生成所有植物的待办任务清单（浇水、施肥）
   */
  public static generateDueTasks(plants: PlantModel[]): CareTaskItem[] {
    const tasks: CareTaskItem[] = [];
    const todayStr = DateUtil.formatDate();

    for (let i = 0; i < plants.length; i++) {
      const plant = plants[i];
      // 1. 浇水任务
      const nextWater = CareScheduler.getNextWaterDate(plant);
      const waterDiff = DateUtil.diffDays(nextWater, todayStr);
      // 只将今日需要或已逾期，或明日即将需要的纳入待办提醒
      if (waterDiff <= 0) {
        tasks.push({
          plantId: plant.id,
          plantName: plant.name,
          nickname: plant.nickname,
          location: plant.location,
          icon: plant.icon,
          actionType: 'water',
          actionName: '浇水',
          dueDate: nextWater,
          diffDays: waterDiff,
          statusDesc: waterDiff < 0 ? `已逾期 ${Math.abs(waterDiff)} 天` : '今日待浇水',
          isOverdue: waterDiff < 0
        });
      }

      // 2. 施肥任务
      const nextFertilize = CareScheduler.getNextFertilizeDate(plant);
      const fertDiff = DateUtil.diffDays(nextFertilize, todayStr);
      if (fertDiff <= 0) {
        tasks.push({
          plantId: plant.id,
          plantName: plant.name,
          nickname: plant.nickname,
          location: plant.location,
          icon: plant.icon,
          actionType: 'fertilize',
          actionName: '施肥',
          dueDate: nextFertilize,
          diffDays: fertDiff,
          statusDesc: fertDiff < 0 ? `施肥已逾期 ${Math.abs(fertDiff)} 天` : '今日待施肥',
          isOverdue: fertDiff < 0
        });
      }
    }

    // 排序：逾期越严重的排在最前
    tasks.sort((a, b) => a.diffDays - b.diffDays);
    return tasks;
  }
}
