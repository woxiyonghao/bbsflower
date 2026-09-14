import { BadgeModel } from '../models/BadgeModel';
import { PlantModel } from '../models/PlantModel';
import { CareLogModel } from '../models/CareLogModel';
import { DiaryModel } from '../models/DiaryModel';

export class BadgeEngine {
  /**
   * 基础徽章预设配置
   */
  public static getAllBadges(
    plants: PlantModel[],
    careLogs: CareLogModel[],
    diaries: DiaryModel[],
    streakDays: number
  ): BadgeModel[] {
    const totalCareCount = careLogs.length;
    const plantCount = plants.length;
    const diaryCount = diaries.length;
    const bloomCount = diaries.filter(d => d.tag === 'bloom').length;
    const repotOrPestCount = diaries.filter(d => d.tag === 'repot' || d.tag === 'pest').length;

    const badges: BadgeModel[] = [
      {
        id: 'bdg_care_1',
        name: '甘霖初至',
        category: 'care',
        categoryName: '养护实践',
        icon: '💧',
        description: '完成第 1 次植物浇水或养护打卡',
        target: 1,
        current: Math.min(totalCareCount, 1),
        isUnlocked: totalCareCount >= 1
      },
      {
        id: 'bdg_care_10',
        name: '润物无声',
        category: 'care',
        categoryName: '养护实践',
        icon: '🌧️',
        description: '累计完成 10 次养护打卡',
        target: 10,
        current: Math.min(totalCareCount, 10),
        isUnlocked: totalCareCount >= 10
      },
      {
        id: 'bdg_care_50',
        name: '百卉滋荣',
        category: 'care',
        categoryName: '养护实践',
        icon: '🏺',
        description: '累计完成 50 次养护打卡，成为绿意守护者',
        target: 50,
        current: Math.min(totalCareCount, 50),
        isUnlocked: totalCareCount >= 50
      },
      {
        id: 'bdg_streak_3',
        name: '绿意初萌',
        category: 'streak',
        categoryName: '长青坚守',
        icon: '🌱',
        description: '连续坚持养护打卡 3 天',
        target: 3,
        current: Math.min(streakDays, 3),
        isUnlocked: streakDays >= 3
      },
      {
        id: 'bdg_streak_7',
        name: '七日坚守',
        category: 'streak',
        categoryName: '长青坚守',
        icon: '⭐',
        description: '连续坚持养护打卡 7 天，养成绿意好习惯',
        target: 7,
        current: Math.min(streakDays, 7),
        isUnlocked: streakDays >= 7
      },
      {
        id: 'bdg_streak_30',
        name: '一月长青',
        category: 'streak',
        categoryName: '长青坚守',
        icon: '👑',
        description: '连续坚持养护打卡 30 天，见证四季流转',
        target: 30,
        current: Math.min(streakDays, 30),
        isUnlocked: streakDays >= 30
      },
      {
        id: 'bdg_garden_1',
        name: '一叶菩提',
        category: 'plant',
        categoryName: '花园规模',
        icon: '🪴',
        description: '在花园中拥有你的第 1 盆花草',
        target: 1,
        current: Math.min(plantCount, 1),
        isUnlocked: plantCount >= 1
      },
      {
        id: 'bdg_garden_3',
        name: '三径芳菲',
        category: 'plant',
        categoryName: '花园规模',
        icon: '🌿',
        description: '在花园中同时精心养护 3 盆植物',
        target: 3,
        current: Math.min(plantCount, 3),
        isUnlocked: plantCount >= 3
      },
      {
        id: 'bdg_garden_8',
        name: '绿野仙踪',
        category: 'plant',
        categoryName: '花园规模',
        icon: '🏡',
        description: '花园规模达到 8 盆，构建私密小森林',
        target: 8,
        current: Math.min(plantCount, 8),
        isUnlocked: plantCount >= 8
      },
      {
        id: 'bdg_diary_1',
        name: '新芽初记',
        category: 'diary',
        categoryName: '成长印记',
        icon: '📝',
        description: '记录下第 1 篇观察笔记或成长日记',
        target: 1,
        current: Math.min(diaryCount, 1),
        isUnlocked: diaryCount >= 1
      },
      {
        id: 'bdg_diary_5',
        name: '芳菲随笔',
        category: 'diary',
        categoryName: '成长印记',
        icon: '📖',
        description: '累计写下 5 篇植物观察日记',
        target: 5,
        current: Math.min(diaryCount, 5),
        isUnlocked: diaryCount >= 5
      },
      {
        id: 'bdg_bloom_1',
        name: '花开见喜',
        category: 'bloom',
        categoryName: '繁花高光',
        icon: '🌸',
        description: '在日记中记录下 1 次开花或花期盛况',
        target: 1,
        current: Math.min(bloomCount, 1),
        isUnlocked: bloomCount >= 1
      },
      {
        id: 'bdg_skill_1',
        name: '妙手回春',
        category: 'care',
        categoryName: '养护进阶',
        icon: '✂️',
        description: '记录 1 次翻盆换土或病害救治心得',
        target: 1,
        current: Math.min(repotOrPestCount, 1),
        isUnlocked: repotOrPestCount >= 1
      }
    ];

    return badges;
  }
}
