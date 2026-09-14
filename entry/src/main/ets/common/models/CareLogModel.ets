/**
 * 养护打卡记录模型
 */
export interface CareLogModel {
  id: string;
  plantId: string;             // 对应植物 ID
  plantName: string;           // 植物名称或昵称
  actionType: string;          // water(浇水), fertilize(施肥), prune(修剪), repot(换盆), mist(叶面喷雾)
  actionName: string;          // 动作名称中文
  date: string;                // 打卡日期 YYYY-MM-DD
  time: string;                // 打卡时间 HH:mm
  note?: string;               // 养护备忘或补充说明
}
