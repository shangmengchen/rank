-- 基于跳表的排行榜系统实现
print("=== Lua排行榜系统 ===")

-- 排行榜系统类
RankSystem = {}
RankSystem.__index = RankSystem

-- 创建排行榜实例
function RankSystem:new()
    local obj = {
        skipList = SkipList(),  -- 使用C++的跳表
        playerData = {},        -- 存储玩家详细信息 {player_id = {name, score, rank}}
        totalPlayers = 0
    }
    setmetatable(obj, self)
    return obj
end

-- 添加玩家到排行榜
function RankSystem:addPlayer(playerId, score, playerName)
    playerName = playerName or "玩家" .. playerId
    
    -- 如果玩家已存在，先删除
    if self.playerData[playerId] then
        self:removePlayer(playerId)
    end
    
    -- 添加到跳表（使用分数作为排序键）
    self.skipList:insert(score)
    
    -- 存储玩家详细信息
    self.playerData[playerId] = {
        name = playerName,
        score = score,
        rank = 0  -- 稍后计算
    }
    
    self.totalPlayers = self.totalPlayers + 1
    
    -- 重新计算所有玩家排名
    self:updateAllRanks()
    
    print(string.format("添加玩家: ID=%d, 名称=%s, 分数=%d", playerId, playerName, score))
end

-- 更新玩家分数
function RankSystem:updateScore(playerId, newScore, newName)
    if not self.playerData[playerId] then
        print("玩家不存在: " .. playerId)
        return false
    end
    
    local oldScore = self.playerData[playerId].score
    local playerName = newName or self.playerData[playerId].name
    
    -- 从跳表中删除旧分数
    self.skipList:erase(oldScore)
    
    -- 添加新分数
    self.skipList:insert(newScore)
    
    -- 更新玩家数据
    self.playerData[playerId].score = newScore
    self.playerData[playerId].name = playerName
    
    -- 重新计算排名
    self:updateAllRanks()
    
    print(string.format("更新玩家分数: ID=%d, 名称=%s, 旧分数=%d, 新分数=%d", 
          playerId, playerName, oldScore, newScore))
    return true
end

-- 删除玩家
function RankSystem:removePlayer(playerId)
    if not self.playerData[playerId] then
        print("玩家不存在: " .. playerId)
        return false
    end
    
    local playerData = self.playerData[playerId]
    
    -- 从跳表中删除
    self.skipList:erase(playerData.score)
    
    -- 从玩家数据中删除
    self.playerData[playerId] = nil
    self.totalPlayers = self.totalPlayers - 1
    
    -- 重新计算排名
    self:updateAllRanks()
    
    print(string.format("删除玩家: ID=%d, 名称=%s, 分数=%d", 
          playerId, playerData.name, playerData.score))
    return true
end

-- 获取玩家排名
function RankSystem:getRank(playerId)
    if not self.playerData[playerId] then
        return -1
    end
    return self.playerData[playerId].rank
end

-- 获取玩家分数
function RankSystem:getScore(playerId)
    if not self.playerData[playerId] then
        return -1
    end
    return self.playerData[playerId].score
end

-- 获取玩家名称
function RankSystem:getPlayerName(playerId)
    if not self.playerData[playerId] then
        return ""
    end
    return self.playerData[playerId].name
end

-- 检查玩家是否存在
function RankSystem:hasPlayer(playerId)
    return self.playerData[playerId] ~= nil
end

-- 获取总玩家数
function RankSystem:getTotalPlayers()
    return self.totalPlayers
end

-- 更新所有玩家排名（内部方法）
function RankSystem:updateAllRanks()
    -- 获取所有分数并排序
    local scores = {}
    for playerId, data in pairs(self.playerData) do
        table.insert(scores, {playerId = playerId, score = data.score})
    end
    
    -- 按分数降序排序
    table.sort(scores, function(a, b) return a.score > b.score end)
    
    -- 更新排名
    for rank, scoreData in ipairs(scores) do
        self.playerData[scoreData.playerId].rank = rank
    end
end

-- 显示排行榜
function RankSystem:displayRankings(topN)
    topN = topN or 10
    print(string.format("\n=== 排行榜 (前%d名) ===", topN))
    print("排名\t玩家ID\t玩家名称\t分数")
    print("----------------------------------------")
    
    -- 获取所有玩家数据并排序
    local players = {}
    for playerId, data in pairs(self.playerData) do
        table.insert(players, {
            id = playerId,
            name = data.name,
            score = data.score,
            rank = data.rank
        })
    end
    
    -- 按排名排序
    table.sort(players, function(a, b) return a.rank < b.rank end)
    
    -- 显示前N名
    local count = 0
    for _, player in ipairs(players) do
        if count >= topN then break end
        print(string.format("%d\t%d\t%s\t\t%d", 
              player.rank, player.id, player.name, player.score))
        count = count + 1
    end
    
    if count == 0 then
        print("排行榜为空")
    end
end

-- 获取前N名玩家
function RankSystem:getTopPlayers(topN)
    topN = topN or 10
    local players = {}
    
    -- 获取所有玩家数据并排序
    local allPlayers = {}
    for playerId, data in pairs(self.playerData) do
        table.insert(allPlayers, {
            id = playerId,
            name = data.name,
            score = data.score,
            rank = data.rank
        })
    end
    
    -- 按排名排序
    table.sort(allPlayers, function(a, b) return a.rank < b.rank end)
    
    -- 返回前N名
    for i = 1, math.min(topN, #allPlayers) do
        table.insert(players, allPlayers[i])
    end
    
    return players
end

-- 获取最高分
function RankSystem:getMaxScore()
    local maxScore = -1
    for _, data in pairs(self.playerData) do
        if data.score > maxScore then
            maxScore = data.score
        end
    end
    return maxScore
end

-- 获取最低分
function RankSystem:getMinScore()
    local minScore = math.huge
    for _, data in pairs(self.playerData) do
        if data.score < minScore then
            minScore = data.score
        end
    end
    return minScore == math.huge and -1 or minScore
end

-- 显示统计信息
function RankSystem:showStats()
    print("\n=== 排行榜统计信息 ===")
    print("总玩家数: " .. self:getTotalPlayers())
    print("最高分: " .. self:getMaxScore())
    print("最低分: " .. self:getMinScore())
end

-- 测试排行榜功能
function testRankSystem()
    print("\n=== 开始测试排行榜系统 ===")
    
    -- 创建排行榜
    local rankSystem = RankSystem:new()
    
    -- 测试1: 添加玩家
    print("\n1. 添加玩家测试")
    rankSystem:addPlayer(1001, 1500, "玩家A")
    rankSystem:addPlayer(1002, 2000, "玩家B")
    rankSystem:addPlayer(1003, 1800, "玩家C")
    rankSystem:addPlayer(1004, 2200, "玩家D")
    rankSystem:addPlayer(1005, 1600, "玩家E")
    
    rankSystem:showStats()
    rankSystem:displayRankings(10)
    
    -- 测试2: 查询玩家信息
    print("\n2. 查询玩家信息测试")
    print("玩家1002的排名: " .. rankSystem:getRank(1002))
    print("玩家1002的分数: " .. rankSystem:getScore(1002))
    print("玩家1002的名称: " .. rankSystem:getPlayerName(1002))
    
    -- 测试3: 更新分数
    print("\n3. 更新分数测试")
    print("玩家1001原分数: " .. rankSystem:getScore(1001))
    rankSystem:updateScore(1001, 2500, "玩家A(更新)")
    print("玩家1001新分数: " .. rankSystem:getScore(1001))
    print("玩家1001新排名: " .. rankSystem:getRank(1001))
    
    print("\n更新后的排行榜:")
    rankSystem:displayRankings(10)
    
    -- 测试4: 添加更多玩家
    print("\n4. 添加更多玩家测试")
    rankSystem:addPlayer(1006, 3000, "玩家F")
    rankSystem:addPlayer(1007, 1200, "玩家G")
    rankSystem:addPlayer(1008, 2800, "玩家H")
    rankSystem:addPlayer(1009, 1900, "玩家I")
    rankSystem:addPlayer(1010, 2100, "玩家J")
    
    rankSystem:showStats()
    print("\n完整排行榜:")
    rankSystem:displayRankings(15)
    
    -- 测试5: 删除玩家
    print("\n5. 删除玩家测试")
    print("删除玩家1007前，总玩家数: " .. rankSystem:getTotalPlayers())
    rankSystem:removePlayer(1007)
    print("删除玩家1007后，总玩家数: " .. rankSystem:getTotalPlayers())
    
    print("\n删除后的排行榜:")
    rankSystem:displayRankings(10)
    
    -- 测试6: 边界情况测试
    print("\n6. 边界情况测试")
    print("查询不存在的玩家1007: " .. (rankSystem:hasPlayer(1007) and "存在" or "不存在"))
    print("查询不存在的玩家排名: " .. rankSystem:getRank(1007))
    print("查询不存在的玩家分数: " .. rankSystem:getScore(1007))
    
    -- 测试7: 相同分数测试
    print("\n7. 相同分数测试")
    rankSystem:addPlayer(1011, 2000, "玩家K")  -- 与玩家B相同分数
    rankSystem:addPlayer(1012, 2000, "玩家L")  -- 与玩家B相同分数
    
    print("\n相同分数测试后的排行榜:")
    rankSystem:displayRankings(12)
    
    -- 测试8: 性能测试
    print("\n8. 性能测试 - 添加大量玩家")
    local startTime = os.clock()
    
    for i = 2000, 2100 do
        local score = math.random(1000, 5000)
        rankSystem:addPlayer(i, score, "测试玩家" .. i)
    end
    
    local endTime = os.clock()
    print("添加100个玩家耗时: " .. (endTime - startTime) .. " 秒")
    rankSystem:showStats()
    
    print("\n最终排行榜前10名:")
    rankSystem:displayRankings(10)
    
    print("\n=== 排行榜系统测试完成 ===")
end

-- 运行测试
testRankSystem()