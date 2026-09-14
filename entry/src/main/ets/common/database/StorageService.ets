import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { PlantModel } from '../models/PlantModel';
import { SpeciesModel } from '../models/SpeciesModel';
import { CareLogModel } from '../models/CareLogModel';
import { DiaryModel } from '../models/DiaryModel';
import {
  DEFAULT_SPECIES_LIST,
  DEFAULT_INITIAL_PLANTS,
  DEFAULT_INITIAL_CARE_LOGS,
  DEFAULT_INITIAL_DIARIES
} from '../constants/DefaultWikiData';

export interface AppDataPayload {
  version: number;
  plants: PlantModel[];
  species: SpeciesModel[];
  careLogs: CareLogModel[];
  diaries: DiaryModel[];
  themeMode: string; // 'system' | 'light' | 'dark'
}

export class StorageService {
  private static instance: StorageService | null = null;
  private context: common.UIAbilityContext | null = null;
  private readonly DATA_FILE_NAME: string = 'bbsflower_sandbox_db.json';

  // 内存状态缓存
  private plants: PlantModel[] = [];
  private species: SpeciesModel[] = [];
  private careLogs: CareLogModel[] = [];
  private diaries: DiaryModel[] = [];
  private themeMode: string = 'system';
  private isLoaded: boolean = false;

  private constructor() {}

  public static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }

  public init(context?: common.UIAbilityContext): void {
    if (context) {
      this.context = context;
    }
    this.loadFromStorage();
  }

  /**
   * 从沙盒加载数据
   */
  public loadFromStorage(): void {
    if (this.isLoaded) {
      return;
    }

    let loadedSuccessfully = false;
    if (this.context && this.context.filesDir) {
      try {
        const filePath = `${this.context.filesDir}/${this.DATA_FILE_NAME}`;
        if (fs.accessSync(filePath)) {
          const jsonStr = fs.readTextSync(filePath);
          if (jsonStr && jsonStr.trim().length > 0) {
            const data = JSON.parse(jsonStr) as AppDataPayload;
            if (data && data.plants) {
              this.plants = data.plants;
              this.species = data.species && data.species.length > 0 ? data.species : DEFAULT_SPECIES_LIST;
              this.careLogs = data.careLogs || [];
              this.diaries = data.diaries || [];
              this.themeMode = data.themeMode || 'system';
              loadedSuccessfully = true;
            }
          }
        }
      } catch (err) {
        // 沙盒读取异常，降级至初始默认数据
      }
    }

    if (!loadedSuccessfully) {
      // 预置初始示范数据
      this.plants = JSON.parse(JSON.stringify(DEFAULT_INITIAL_PLANTS)) as PlantModel[];
      this.species = JSON.parse(JSON.stringify(DEFAULT_SPECIES_LIST)) as SpeciesModel[];
      this.careLogs = JSON.parse(JSON.stringify(DEFAULT_INITIAL_CARE_LOGS)) as CareLogModel[];
      this.diaries = JSON.parse(JSON.stringify(DEFAULT_INITIAL_DIARIES)) as DiaryModel[];
      this.themeMode = 'system';
      this.saveToStorage();
    }

    this.isLoaded = true;
  }

  /**
   * 持久化到沙盒文件
   */
  public saveToStorage(): boolean {
    if (!this.context || !this.context.filesDir) {
      return false;
    }
    try {
      const filePath = `${this.context.filesDir}/${this.DATA_FILE_NAME}`;
      const payload: AppDataPayload = {
        version: 1,
        plants: this.plants,
        species: this.species,
        careLogs: this.careLogs,
        diaries: this.diaries,
        themeMode: this.themeMode
      };
      const jsonStr = JSON.stringify(payload);
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, jsonStr);
      fs.closeSync(file);
      return true;
    } catch (err) {
      return false;
    }
  }

  // ============== 花盆 (Plants) 业务操作 ==============

  public getPlants(): PlantModel[] {
    return this.plants;
  }

  public getPlantById(id: string): PlantModel | null {
    const found = this.plants.find(p => p.id === id);
    return found ? found : null;
  }

  public savePlant(plant: PlantModel): void {
    const index = this.plants.findIndex(p => p.id === plant.id);
    if (index >= 0) {
      this.plants[index] = plant;
    } else {
      this.plants.unshift(plant);
    }
    this.saveToStorage();
  }

  public deletePlant(id: string): void {
    this.plants = this.plants.filter(p => p.id !== id);
    // 同时清理相关记录或保留历史
    this.saveToStorage();
  }

  // ============== 花种百科 (Species) 操作 ==============

  public getSpecies(): SpeciesModel[] {
    return this.species;
  }

  public getSpeciesById(id: string): SpeciesModel | null {
    const found = this.species.find(s => s.id === id);
    return found ? found : null;
  }

  // ============== 打卡记录 (CareLogs) 操作 ==============

  public getCareLogs(): CareLogModel[] {
    return this.careLogs;
  }

  public addCareLog(log: CareLogModel): void {
    this.careLogs.unshift(log);
    // 同步更新植物最后浇水/施肥时间
    const plant = this.getPlantById(log.plantId);
    if (plant) {
      if (log.actionType === 'water') {
        plant.lastWaterDate = log.date;
      } else if (log.actionType === 'fertilize') {
        plant.lastFertilizeDate = log.date;
      }
      this.savePlant(plant);
    } else {
      this.saveToStorage();
    }
  }

  public deleteCareLog(id: string): void {
    this.careLogs = this.careLogs.filter(l => l.id !== id);
    this.saveToStorage();
  }

  // ============== 日记与观察心得 (Diaries) 操作 ==============

  public getDiaries(): DiaryModel[] {
    return this.diaries;
  }

  public addDiary(diary: DiaryModel): void {
    this.diaries.unshift(diary);
    this.saveToStorage();
  }

  public deleteDiary(id: string): void {
    this.diaries = this.diaries.filter(d => d.id !== id);
    this.saveToStorage();
  }

  // ============== 主题与设置 ==============

  public getThemeMode(): string {
    return this.themeMode;
  }

  public setThemeMode(mode: string): void {
    this.themeMode = mode;
    this.saveToStorage();
  }

  // ============== 数据全量备份与导入恢复 ==============

  public exportDataAsJson(): string {
    const payload: AppDataPayload = {
      version: 1,
      plants: this.plants,
      species: this.species,
      careLogs: this.careLogs,
      diaries: this.diaries,
      themeMode: this.themeMode
    };
    return JSON.stringify(payload, null, 2);
  }

  public importDataFromJson(jsonStr: string): boolean {
    try {
      const data = JSON.parse(jsonStr) as AppDataPayload;
      if (data && Array.isArray(data.plants)) {
        this.plants = data.plants;
        if (Array.isArray(data.species) && data.species.length > 0) {
          this.species = data.species;
        }
        this.careLogs = Array.isArray(data.careLogs) ? data.careLogs : [];
        this.diaries = Array.isArray(data.diaries) ? data.diaries : [];
        this.themeMode = data.themeMode || 'system';
        this.saveToStorage();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  public resetToSampleData(): void {
    this.plants = JSON.parse(JSON.stringify(DEFAULT_INITIAL_PLANTS)) as PlantModel[];
    this.species = JSON.parse(JSON.stringify(DEFAULT_SPECIES_LIST)) as SpeciesModel[];
    this.careLogs = JSON.parse(JSON.stringify(DEFAULT_INITIAL_CARE_LOGS)) as CareLogModel[];
    this.diaries = JSON.parse(JSON.stringify(DEFAULT_INITIAL_DIARIES)) as DiaryModel[];
    this.saveToStorage();
  }
}
