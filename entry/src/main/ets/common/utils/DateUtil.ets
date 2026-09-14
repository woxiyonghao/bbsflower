/**
 * 日历与时间处理工具
 */

export interface CalendarDayInfo {
  dateStr: string;        // YYYY-MM-DD
  dayNum: number;         // 几号
  isCurrentMonth: boolean;// 是否当月
  isToday: boolean;       // 是否今天
  hasCareAction: boolean; // 是否有养护打卡
  hasDiary: boolean;      // 是否有日记
  actionCount: number;    // 当天养护次数
}

export class DateUtil {
  /**
   * 补零辅助
   */
  private static padZero(n: number): string {
    return n < 10 ? `0${n}` : `${n}`;
  }

  /**
   * 格式化 Date 为 YYYY-MM-DD
   */
  public static formatDate(d: Date = new Date()): string {
    const year = d.getFullYear();
    const month = DateUtil.padZero(d.getMonth() + 1);
    const day = DateUtil.padZero(d.getDate());
    return `${year}-${month}-${day}`;
  }

  /**
   * 格式化时间为 HH:mm
   */
  public static formatTime(d: Date = new Date()): string {
    const hours = DateUtil.padZero(d.getHours());
    const minutes = DateUtil.padZero(d.getMinutes());
    return `${hours}:${minutes}`;
  }

  /**
   * 得到中文日期，如 "9月14日 星期一"
   */
  public static getChineseDate(d: Date = new Date()): string {
    const month = d.getMonth() + 1;
    const day = d.getDate();
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    const weekDay = weekDays[d.getDay()];
    return `${month}月${day}日 ${weekDay}`;
  }

  /**
   * 给指定日期增加天数
   */
  public static addDays(dateStr: string, days: number): string {
    const parts = dateStr.split('-');
    if (parts.length < 3) {
      return dateStr;
    }
    const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
    d.setDate(d.getDate() + days);
    return DateUtil.formatDate(d);
  }

  /**
   * 计算日期差（target - base），单位天数
   */
  public static diffDays(targetDateStr: string, baseDateStr: string): number {
    const tp = targetDateStr.split('-');
    const bp = baseDateStr.split('-');
    if (tp.length < 3 || bp.length < 3) {
      return 0;
    }
    const target = new Date(parseInt(tp[0]), parseInt(tp[1]) - 1, parseInt(tp[2])).getTime();
    const base = new Date(parseInt(bp[0]), parseInt(bp[1]) - 1, parseInt(bp[2])).getTime();
    return Math.round((target - base) / (1000 * 60 * 60 * 24));
  }

  /**
   * 友好的相对倒计时显示，如 "今日需浇水"、"已逾期2天"、"还有3天"
   */
  public static getRemainingDaysDesc(nextCareDateStr: string, todayStr: string): string {
    const diff = DateUtil.diffDays(nextCareDateStr, todayStr);
    if (diff < 0) {
      return `已逾期 ${Math.abs(diff)} 天`;
    } else if (diff === 0) {
      return '今日需养护';
    } else if (diff === 1) {
      return '明日需养护';
    } else {
      return `还有 ${diff} 天`;
    }
  }

  /**
   * 生成月度日历网格数据 (42格 / 6周)
   */
  public static generateMonthGrid(
    year: number,
    month: number, // 1-12
    careDates: string[],
    diaryDates: string[]
  ): CalendarDayInfo[] {
    const grid: CalendarDayInfo[] = [];
    const todayStr = DateUtil.formatDate();

    // 当月第一天
    const firstDay = new Date(year, month - 1, 1);
    // 第一天是周几 (0是周日)
    const startWeekDay = firstDay.getDay();

    // 上个月要补足的天数
    const prevMonthLastDate = new Date(year, month - 1, 0).getDate();
    for (let i = startWeekDay - 1; i >= 0; i--) {
      const dayNum = prevMonthLastDate - i;
      const prevM = month === 1 ? 12 : month - 1;
      const prevY = month === 1 ? year - 1 : year;
      const dateStr = `${prevY}-${DateUtil.padZero(prevM)}-${DateUtil.padZero(dayNum)}`;
      const actCount = careDates.filter(d => d === dateStr).length;
      grid.push({
        dateStr: dateStr,
        dayNum: dayNum,
        isCurrentMonth: false,
        isToday: dateStr === todayStr,
        hasCareAction: actCount > 0,
        hasDiary: diaryDates.indexOf(dateStr) !== -1,
        actionCount: actCount
      });
    }

    // 当月天数
    const currentMonthDays = new Date(year, month, 0).getDate();
    for (let day = 1; day <= currentMonthDays; day++) {
      const dateStr = `${year}-${DateUtil.padZero(month)}-${DateUtil.padZero(day)}`;
      const actCount = careDates.filter(d => d === dateStr).length;
      grid.push({
        dateStr: dateStr,
        dayNum: day,
        isCurrentMonth: true,
        isToday: dateStr === todayStr,
        hasCareAction: actCount > 0,
        hasDiary: diaryDates.indexOf(dateStr) !== -1,
        actionCount: actCount
      });
    }

    // 下个月补足至 35 或 42 格
    const totalCurrent = grid.length;
    const targetTotal = totalCurrent > 35 ? 42 : 35;
    const remaining = targetTotal - totalCurrent;
    for (let i = 1; i <= remaining; i++) {
      const nextM = month === 12 ? 1 : month + 1;
      const nextY = month === 12 ? year + 1 : year;
      const dateStr = `${nextY}-${DateUtil.padZero(nextM)}-${DateUtil.padZero(i)}`;
      const actCount = careDates.filter(d => d === dateStr).length;
      grid.push({
        dateStr: dateStr,
        dayNum: i,
        isCurrentMonth: false,
        isToday: dateStr === todayStr,
        hasCareAction: actCount > 0,
        hasDiary: diaryDates.indexOf(dateStr) !== -1,
        actionCount: actCount
      });
    }

    return grid;
  }

  /**
   * 计算连续打卡天数 (连续打卡 Streak)
   */
  public static calculateStreak(careDates: string[]): number {
    if (careDates.length === 0) {
      return 0;
    }
    // 去重并按日期倒序
    const uniqueDates = Array.from(new Set(careDates)).sort((a, b) => b.localeCompare(a));
    const todayStr = DateUtil.formatDate();
    const yesterdayStr = DateUtil.addDays(todayStr, -1);

    let currentIndex = 0;
    // 检查今天或者昨天是否有打卡，没有则连续中断
    if (uniqueDates[0] === todayStr) {
      currentIndex = 0;
    } else if (uniqueDates[0] === yesterdayStr) {
      currentIndex = 0;
    } else {
      return 0;
    }

    let streak = 1;
    let checkDateStr = uniqueDates[currentIndex];

    for (let i = currentIndex + 1; i < uniqueDates.length; i++) {
      const expectedPrev = DateUtil.addDays(checkDateStr, -1);
      if (uniqueDates[i] === expectedPrev) {
        streak++;
        checkDateStr = expectedPrev;
      } else {
        break;
      }
    }

    return streak;
  }
}
