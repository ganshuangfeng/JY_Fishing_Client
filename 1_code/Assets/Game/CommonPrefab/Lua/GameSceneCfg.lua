--[[
state: 1开启 2未开启 3尽请期待
type:  1斗地主 2麻将
]]--

-- SceneName=场景名称，也就是要跳转的游戏场景
GameSceneCfg = {
	[0] = {ID = 0, PanelName = "HallPanel", SceneName = "game_Hall", GameTitle = "大厅", GameName = "大厅"},
	[1] = {ID = 1, PanelName = "HallPanel", SceneName = "game_DdzMatch", GameTitle = "锦标赛", GameName = "斗地主比赛场"},
	[2] = {ID = 2, PanelName = "HallPanel", SceneName = "game_DdzFree", GameTitle = "练习场", GameName = "斗地主匹配场"},
	[3] = {ID = 3, PanelName = "HallPanel", SceneName = "game_DdzMillion", GameTitle = "百万大奖赛", GameName = "百万大奖赛"},

	[4] = {ID = 4, PanelName = "", SceneName = "game_DdzFree", GameTitle = "经典斗地主", GameName = "斗地主匹配场"},
	[5] = {ID = 5, PanelName = "", SceneName = "game_DdzFree", GameTitle = "癞子斗地主", GameName = "癞子斗地主匹配场"},
	[6] = {ID = 6, PanelName = "", SceneName = "game_DdzTy", GameTitle = "听用斗地主", GameName = "斗地主听用场"},
	[7] = {ID = 7, PanelName = "", SceneName = "game_DdzFree", GameTitle = "练习场", GameName = "斗地主匹配场"},
	[8] = {ID = 8, PanelName = "", SceneName = "game_Mj3D", GameTitle = "血战到底", GameName = "麻将匹配场"},
	[9] = {ID = 9, PanelName = "", SceneName = "game_MjXl3D", GameTitle = "血流到底", GameName = "麻将血流匹配场"},
	[10] = {ID = 10, PanelName = "", SceneName = "", GameTitle = nil, GameName = "期待"},
	[11] = {ID = 11, PanelName = "", SceneName = "", GameTitle = nil, GameName = "期待"},
	[12] = {ID = 12, PanelName = "", SceneName = "game_MjXzFK3D", GameTitle = "血战到底房卡场", GameName = "血战到底房卡场"},
	[13] = {ID = 13, PanelName = "", SceneName = "game_DdzFK", GameTitle = "斗地主房卡场", GameName = "斗地主房卡场"},
	[14] = {ID = 14, PanelName = "HallPanel", SceneName = "game_CityMatch", GameTitle = "鲸鱼杯", GameName = "斗地主鲸鱼杯"},
	[15] = {ID = 15, PanelName = "HallPanel", SceneName = "game_DdzMatchER", GameTitle = "2人斗地主比赛场", GameName = "2人斗地主比赛场"},
	[16] = {ID = 16, PanelName = "HallPanel", SceneName = "game_MjXzMatchER3D", GameTitle = "2人血战麻将比赛场", GameName = "2人血战麻将比赛场"},
	[17] = {ID = 17, PanelName = "HallPanel", SceneName = "game_DdzFree", GameTitle = "2人斗地主匹配场", GameName = "2人斗地主匹配场"},
	[18] = {ID = 18, PanelName = "HallPanel", SceneName = "game_Mj3D", GameTitle = "2人麻将匹配场", GameName = "2人麻将匹配场"},
	[19] = {ID = 19, PanelName = "HallPanel", SceneName = "game_Free", GameTitle = "匹配界面", GameName = "匹配界面"},
	[20] = {ID = 20, PanelName = "HallPanel", SceneName = "game_Match", GameTitle = "比赛界面", GameName = "比赛界面"},
	[21] = {ID = 21, PanelName = "HallPanel", SceneName = "game_DdzMatch", GameTitle = "冠名赛", GameName = "斗地主冠名赛场"},
	[22] = {ID = 22, PanelName = "HallPanel", SceneName = "game_MjXzMatchER3D", GameTitle = "血战麻将比赛场", GameName = "血战麻将比赛场"},
	[23] = {ID = 23, PanelName = "HallPanel", SceneName = "game_DdzFree", GameTitle = "天府斗地主", GameName = "天府斗地主"},
	[24] = {ID = 24, PanelName = "HallPanel", SceneName = "game_MjXzMatchER3D", GameTitle = "麻将冠名赛场", GameName = "麻将冠名赛场"},
	[25] = {ID = 25, PanelName = "HallPanel", SceneName = "game_Gobang", GameTitle = "五子棋", GameName = "五子棋"},
	[26] = {ID = 26, PanelName = "", SceneName = "game_DdzFree", GameTitle = "经典斗地主", GameName = "斗地主匹配场"},
	[27] = {ID = 27, PanelName = "HallPanel", SceneName = "game_Fishing", GameTitle = "捕鱼游戏", GameName = "捕鱼游戏"},
	[28] = {ID = 28, PanelName = "HallPanel", SceneName = "game_FishingHall", GameTitle = "捕鱼大厅", GameName = "捕鱼大厅"},
	[29] = {ID = 29, PanelName = "Eliminate", SceneName = "game_Eliminate", GameTitle = "消消乐", GameName = "消消乐"},
	[30] = {ID = 30, PanelName = "MiniGameHallPanel", SceneName = "game_MiniGame", GameTitle = "小游戏", GameName = "小游戏"},
	[31] = {ID = 31, PanelName = "ShatterGoldenEggPanel", SceneName = "game_Zjd", GameTitle = "敲敲乐", GameName = "敲敲乐"},
	[32] = {ID = 32, PanelName = "HallPanel", SceneName = "game_FishingDR", GameTitle = "疯狂捕鱼", GameName = "疯狂捕鱼"},
	[33] = {ID = 33, PanelName = "HallPanel", SceneName = "game_FishingMatch", GameTitle = "捕鱼比赛", GameName = "捕鱼比赛"},
	[34] = {ID = 34, PanelName = "HallPanel", SceneName = "game_EliminateSH", GameTitle = "水浒消消乐", GameName = "水浒消消乐"},
	[35] = {ID = 35, PanelName = "HallPanel", SceneName = "game_DdzPDK", GameTitle = "跑得快", GameName = "跑得快"},
	[36] = {ID = 36, PanelName = "HallPanel", SceneName = "game_LHD", GameTitle = "金蛋大乱斗", GameName = "金蛋大乱斗"},
	[37] = {ID = 37, PanelName = "HallPanel", SceneName = "game_LHDHall", GameTitle = "金蛋大乱斗大厅", GameName = "金蛋大乱斗大厅"},
	[38] = {ID = 38, PanelName = "HallPanel", SceneName = "game_DdzPDKMatch", GameTitle = "跑得快锦标赛", GameName = "跑得快锦标赛"},
	[39] = {ID = 39, PanelName = "HallPanel", SceneName = "game_QHB", GameTitle = "抢红包", GameName = "抢红包"},
	[40] = {ID = 40, PanelName = "HallPanel", SceneName = "game_QHBHall", GameTitle = "抢红包大厅", GameName = "抢红包"},
	[41] = {ID = 41, PanelName = "HallPanel", SceneName = "game_Fishing3DHall", GameTitle = "3D捕鱼大厅", GameName = "3D捕鱼大厅"},
	[42] = {ID = 42, PanelName = "HallPanel", SceneName = "game_Fishing3D", GameTitle = "3D捕鱼游戏", GameName = "3D捕鱼游戏"},
	[43] = {ID = 41, PanelName = "HallPanel", SceneName = "game_EliminateCS", GameTitle = "财神消消乐", GameName = "财神消消乐"},
	[44] = {ID = 44, PanelName = "HallPanel", SceneName = "game_TTL", GameTitle = "弹弹乐", GameName = "弹弹乐"},
	[45] = {ID = 45, PanelName = "HallPanel", SceneName = "game_ZPG", GameTitle = "苹果大战", GameName = "苹果大战"},

	[46] = {ID = 46, PanelName = "HallPanel", SceneName = "game_DdzZJF", GameTitle = "二人斗地主自建房", GameName = "二人斗地主自建房"},
	[47] = {ID = 47, PanelName = "HallPanel", SceneName = "game_DdzZJF", GameTitle = "炸弹斗地主自建房", GameName = "炸弹斗地主自建房"},
	[48] = {ID = 48, PanelName = "HallPanel", SceneName = "game_ZJF", GameTitle = "自建房匹配界面", GameName = "自建房匹配界面"},
	[49] = {ID = 49, PanelName = "HallPanel", SceneName = "game_DdzZJF", GameTitle = "经典斗地主自建房", GameName = "经典斗地主自建房"},
	[50] = {ID = 50, PanelName = "HallPanel", SceneName = "game_DdzZJF", GameTitle = "癞子斗地主自建房", GameName = "癞子斗地主自建房"},
	[51] = {ID = 51, PanelName = "HallPanel", SceneName = "game_MJXzZJF3D", GameTitle = "麻将血战到底自建房", GameName = "麻将血战到底自建房"},
	[52] = {ID = 52, PanelName = "HallPanel", SceneName = "game_MJXzZJF3D", GameTitle = "二人麻将自建房", GameName = "二人麻将自建房"},
	[53] = {ID = 53, PanelName = "HallPanel", SceneName = "game_FishingMatchQYS", GameTitle = "捕鱼红包比赛", GameName = "捕鱼红包比赛"},

	[54] = {ID = 54, PanelName = "HallPanel", SceneName = "game_FishingMatchHall", GameTitle = "捕鱼比赛大厅", GameName = "捕鱼比赛大厅"},
	[55] = {ID = 55, PanelName = "HallPanel", SceneName = "game_EliminateXY", GameTitle = "西游消消乐", GameName = "西游消消乐"},
	[56] = {ID = 56, PanelName = "HallPanel", SceneName = "game_Fishing3DBossHall", GameTitle = "3D捕鱼Boss场", GameName = "3D捕鱼Boss场"},

	[57] = {ID = 57, PanelName = "HallPanel", SceneName = "game_FishFarm", GameTitle = "养鱼", GameName = "养鱼"},

	[58] = {ID = 58, PanelName = "HallPanel", SceneName = "game_LWZBHall", GameTitle = "龙王争霸大厅", GameName = "龙王争霸大厅"},
	[59] = {ID = 59, PanelName = "HallPanel", SceneName = "game_LWZB", GameTitle = "龙王争霸", GameName = "龙王争霸"},
	[60] = {ID = 60, PanelName = "HallPanel", SceneName = "game_EliminateSG", GameTitle = "三国消消乐", GameName = "三国消消乐"},

	[100] = {ID = 100, PanelName = "HallPanel", SceneName = "game_FishingTest", GameTitle = "捕鱼调试", GameName = "捕鱼调试"},
}


-- key=游戏类型名称 value=游戏配置
GameConfigToSceneCfg = {
	game_Hall = GameSceneCfg[0],
	game_DdzMatch = GameSceneCfg[1],
	game_DdzMillion = GameSceneCfg[3],
	game_DdzFree = GameSceneCfg[4],
	game_DdzLaizi = GameSceneCfg[5],
	game_DdzTy = GameSceneCfg[6],

	game_Mj3D = GameSceneCfg[8],
	game_MjXl3D = GameSceneCfg[9],
	game_MjXzFK3D = GameSceneCfg[12],

	game_DdzFK = GameSceneCfg[13],
	game_CityMatch = GameSceneCfg[14],
	game_DdzMatchER = GameSceneCfg[15],
	game_MjXzMatchER3D = GameSceneCfg[16],
	game_DdzFreeER = GameSceneCfg[17],
	game_MjXzER3D = GameSceneCfg[18],
	game_Free = GameSceneCfg[19],
	game_Match = GameSceneCfg[20],
	game_DdzMatchNaming = GameSceneCfg[21],
	game_MjXzMatch3D = GameSceneCfg[22],
	game_DdzFreeTF = GameSceneCfg[23],
	game_MjMatchNaming = GameSceneCfg[24],
	game_Gobang = GameSceneCfg[25],
	game_DdzFreeBomb = GameSceneCfg[26],
	game_Fishing = GameSceneCfg[27],
	game_FishingHall = GameSceneCfg[28],
	game_Eliminate = GameSceneCfg[29],
	game_MiniGame = GameSceneCfg[30],
	game_Zjd = GameSceneCfg[31],
	game_FishingDR = GameSceneCfg[32],
	game_FishingMatch = GameSceneCfg[33],
	game_EliminateSH = GameSceneCfg[34],
	game_DdzPDK = GameSceneCfg[35],
	game_LHD = GameSceneCfg[36],
	game_LHDHall = GameSceneCfg[37],
	game_DdzPDKMatch = GameSceneCfg[38],
	game_QHB = GameSceneCfg[39],
	game_QHBHall = GameSceneCfg[40],
	game_Fishing3DHall = GameSceneCfg[41],
	game_Fishing3D = GameSceneCfg[42],
	game_EliminateCS = GameSceneCfg[43],
	game_TTL= GameSceneCfg[44],
	game_ZPG = GameSceneCfg[45],
	game_DdzZJF = GameSceneCfg[49],
	game_ZJF = GameSceneCfg[48],
	game_DdzLaiziZJF = GameSceneCfg[50],
	game_DdzERZJF = GameSceneCfg[46],
	game_DdzBombZJF = GameSceneCfg[47],
	game_Mj3dERZJF = GameSceneCfg[52],
	game_MJXzZJF3D = GameSceneCfg[51],
	game_Mj3dXZDDZJF = GameSceneCfg[51],
	game_FishingMatchQYS = GameSceneCfg[53],
	game_FishingMatchHall = GameSceneCfg[54],
	game_EliminateXY = GameSceneCfg[55],
	game_Fishing3DBossHall = GameSceneCfg[56],
	game_FishFarm = GameSceneCfg[57],

	game_LWZBHall = GameSceneCfg[58],
	game_LWZB = GameSceneCfg[59],

	game_EliminateSG = GameSceneCfg[60],

	game_FishingTest = GameSceneCfg[100],
}