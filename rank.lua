-- 基于跳表的排行榜系统实现
print("=== Lua排行榜系统 (真正使用跳表排序) ===")

-- 排行榜系统类
RankSystem = {}
-- obj找不到，去原表的index找
RankSystem.__index = RankSystem

-- 创建排行榜实例
function RankSystem:new()
    local obj = {
        skipList = SkipList(),  -- 使用C++的跳表进行排序
        playerData = {},        -- 存储玩家详细信息 {player_id = {name, score}}
        scoreToPlayers = {},    -- 分数到玩家列表的映射 {score = {player_id1, player_id2, ...}}
        totalPlayers = 0
    }
    -- 后者是前者的原表
    -- 相当于 RankSystem 是个类，obj是类的实例
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
    
    -- 存储玩家详细信息
    self.playerData[playerId] = {
        name = playerName,
        score = score
    }
    
    -- 将玩家添加到分数映射中
    if not self.scoreToPlayers[score] then
        self.scoreToPlayers[score] = {}
        -- 只有新分数才需要插入跳表
        self.skipList:insert(score)
    end
    table.insert(self.scoreToPlayers[score], playerId)
    
    self.totalPlayers = self.totalPlayers + 1
    
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
    
    -- 从旧分数的玩家列表中移除
    local oldPlayers = self.scoreToPlayers[oldScore]
    for i, id in ipairs(oldPlayers) do
        if id == playerId then
            table.remove(oldPlayers, i)
            break
        end
    end
    
    -- 如果旧分数没有玩家了，从跳表中删除
    if #oldPlayers == 0 then
        self.scoreToPlayers[oldScore] = nil
        self.skipList:erase(oldScore)
    end
    
    -- 更新玩家数据
    self.playerData[playerId].score = newScore
    self.playerData[playerId].name = playerName
    
    -- 添加到新分数的玩家列表
    if not self.scoreToPlayers[newScore] then
        self.scoreToPlayers[newScore] = {}
        -- 只有新分数才需要插入跳表
        self.skipList:insert(newScore)
    end
    table.insert(self.scoreToPlayers[newScore], playerId)
    
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
    local score = playerData.score
    
    -- 从分数映射中移除玩家
    local players = self.scoreToPlayers[score]
    for i, id in ipairs(players) do
        if id == playerId then
            table.remove(players, i)
            break
        end
    end
    
    -- 如果该分数没有玩家了，从跳表中删除
    if #players == 0 then
        self.scoreToPlayers[score] = nil
        self.skipList:erase(score)
    end
    
    -- 从玩家数据中删除
    self.playerData[playerId] = nil
    self.totalPlayers = self.totalPlayers - 1
    
    print(string.format("删除玩家: ID=%d, 名称=%s, 分数=%d", 
          playerId, playerData.name, playerData.score))
    return true
end

-- 获取玩家排名（O(log n)）
function RankSystem:getRank(playerId)
    if not self.playerData[playerId] then
        return -1
    end
    local score = self.playerData[playerId].score
    local rankBase = self.skipList:getRankByScore(score)
    if rankBase < 0 then return -1 end

    -- 相同分数时再在本地表中定位
    local playersAtScore = self.scoreToPlayers[score]
    table.sort(playersAtScore)
    for i, id in ipairs(playersAtScore) do
        if id == playerId then
            return rankBase + i - 1
        end
    end
    return -1
end


-- 获取所有分数（按降序排列）
function RankSystem:getAllScoresSorted()
    local scores = {}
    
    -- 从跳表中获取所有分数（升序）
    -- 由于跳表是升序，我们需要反转得到降序
    local tempScores = {}
    
    -- 这里我们需要遍历跳表，但由于跳表没有提供遍历接口
    -- 我们直接从scoreToPlayers中获取所有分数并排序
    for score, _ in pairs(self.scoreToPlayers) do
        table.insert(tempScores, score)
    end
    
    -- 按分数降序排序
    table.sort(tempScores, function(a, b) return a > b end)
    
    return tempScores
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

-- 显示排行榜（基于跳表排序）
function RankSystem:displayRankings(topN)
    topN = topN or 10
    print(string.format("\n=== 排行榜 (前%d名) ===", topN))
    print("排名\t玩家ID\t玩家名称\t分数")
    print("----------------------------------------")
    
    local scores = self:getAllScoresSorted()
    local rank = 1
    local count = 0
    
    for _, score in ipairs(scores) do
        local playersAtScore = self.scoreToPlayers[score]
        
        -- 按玩家ID排序，确保相同分数的玩家有稳定的排序
        table.sort(playersAtScore)
        
        for _, playerId in ipairs(playersAtScore) do
            if count >= topN then break end
            
            local playerData = self.playerData[playerId]
            print(string.format("%d\t%d\t%s\t\t%d", 
                  rank, playerId, playerData.name, score))
            
            rank = rank + 1
            count = count + 1
        end
        
        if count >= topN then break end
    end
    
    if count == 0 then
        print("排行榜为空")
    end
end

-- 获取前N名玩家
function RankSystem:getTopPlayers(topN)
    topN = topN or 10
    local players = {}
    
    local scores = self:getAllScoresSorted()
    local rank = 1
    local count = 0
    
    for _, score in ipairs(scores) do
        local playersAtScore = self.scoreToPlayers[score]
        table.sort(playersAtScore)  -- 按玩家ID排序
        
        for _, playerId in ipairs(playersAtScore) do
            if count >= topN then break end
            
            local playerData = self.playerData[playerId]
            table.insert(players, {
                rank = rank,
                id = playerId,
                name = playerData.name,
                score = score
            })
            
            rank = rank + 1
            count = count + 1
        end
        
        if count >= topN then break end
    end
    
    return players
end

-- 获取最高分
function RankSystem:getMaxScore()
    local scores = self:getAllScoresSorted()
    return #scores > 0 and scores[1] or -1
end

-- 获取最低分
function RankSystem:getMinScore()
    local scores = self:getAllScoresSorted()
    return #scores > 0 and scores[#scores] or -1
end

-- 显示统计信息
function RankSystem:showStats()
    print("\n=== 排行榜统计信息 ===")
    print("总玩家数: " .. self:getTotalPlayers())
    print("最高分: " .. self:getMaxScore())
    print("最低分: " .. self:getMinScore())
    print("不同分数数量: " .. self:getUniqueScoreCount())
end

-- 获取不同分数的数量
function RankSystem:getUniqueScoreCount()
    local count = 0
    for _ in pairs(self.scoreToPlayers) do
        count = count + 1
    end
    return count
end

-- 显示跳表结构（调试用）
function RankSystem:displaySkipList()
    print("\n=== 跳表结构 ===")
    self.skipList:display()
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
    
    -- 显示跳表结构
    rankSystem:displaySkipList()
    
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
    rankSystem:displaySkipList()
    
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
    
    -- 测试6: 相同分数测试
    print("\n6. 相同分数测试")
    rankSystem:addPlayer(1011, 2000, "玩家K")  -- 与玩家B相同分数
    rankSystem:addPlayer(1012, 2000, "玩家L")  -- 与玩家B相同分数
    
    print("\n相同分数测试后的排行榜:")
    rankSystem:displayRankings(12)
    rankSystem:displaySkipList()
    
    -- 测试7: 性能测试
    print("\n7. 性能测试 - 添加大量玩家")
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