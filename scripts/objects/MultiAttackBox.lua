local MultiAttackBox, super = Class(Object)

MultiAttackBox.CRITICAL = 22

function MultiAttackBox:init(battler, offset, x, y)
    super:init(self, x, y)

    self.color_type = Kristal.getLibConfig("multihitlib", "colortype")

    self.battler = battler
    self.offset = offset
    self.weapon = battler.chara:getWeapon()

    self.head_sprite = Sprite(battler.chara:getHeadIcons().."/head", 21, 19)
    self.head_sprite:setOrigin(0.5, 0.5)
    self:addChild(self.head_sprite)

    self.press_sprite = Sprite("ui/battle/press", 42, 0)
    self:addChild(self.press_sprite)

    self.bolt_target = 80 + 2
    self.bolt_start_x = self.bolt_target + ((self.offset * self.weapon:getBoltSpeed()))

    self.bolts = {}
    self.score = 0

    for i = 1, self.weapon:getBoltCount() do
        local bolt = AttackBar(self.bolt_start_x + ((i * 80) - 160), 0, 6, 38)
        bolt.layer = 1
        self.bolts[i] = bolt
        self:addChild(bolt)
    end

    self.fade_rect = Rectangle(0, 0, SCREEN_WIDTH, 38)
    self.fade_rect:setColor(0, 0, 0, 0)
    self.fade_rect.layer = 2
    self:addChild(self.fade_rect)

    self.afterimage_timer = 0
    self.afterimage_count = -1

    self.flash = 0

    self.attacked = false
end

function MultiAttackBox:getClose()
    return Utils.round((self.bolts[1].x - self.bolt_target) / self.weapon:getBoltLeniency())
end

function MultiAttackBox:hit()
    local bolt = self.bolts[1]

    self.score = self.score + self:evaluateHit(self:getClose())

    if self:getClose() >= 0 and self:getClose() <= 0 then
        Assets.stopAndPlaySound("victor", 1.2)
        bolt:setColor(1, 1, 0)
        bolt.burst_speed = 0.2
    elseif self:getClose() >= 6 or self:getClose() <= -3 then
        bolt:setColor(1, 80/255, 80/255, 1)
    else
        Assets.stopAndPlaySound("hit", 1.1)
        bolt:setColor(self.battler.chara:getDamageColor())
    end

    bolt:burst()
    bolt.layer = 1
    bolt:setPosition(bolt:getRelativePos(0, 0, self.parent))
    bolt:setParent(self.parent)

    table.remove(self.bolts, 1)

    return self:evaluateScore()

end

function MultiAttackBox:miss()
    self.bolts[1]:fadeOutSpeedAndRemove(0.4)
    
    table.remove(self.bolts, 1)

    return self:evaluateScore()
end

function MultiAttackBox:evaluateHit(value)
    if value < -1 then
        return 50
    elseif value < 0 then
        return 70
    elseif value < 1 then
        return 105 -- perfect
    elseif value < 2 then
        return 85
    elseif value < 3 then
        return 70
    elseif value < 6 then
        return 40
    elseif value < 8 then
        return 25
    elseif value < 11 then
        return 20
    else
        return 10
    end
end

function MultiAttackBox:evaluateScore()
    if #self.bolts == 0 then
        self.attacked = true
    end

    if self.attacked then
        local perfect_score = 105 * self.weapon:getBoltCount()

        if perfect_score - self.score <= MultiAttackBox.CRITICAL then
            return 150
        elseif perfect_score - self.score <= 70 then
            return 120
        elseif perfect_score - self.score <= 120 then
            return 110
        else
            return math.min(self.score, 60)
        end
    end
end

function MultiAttackBox:update()

    if Game.battle.cancel_attack then
        self.fade_rect.alpha = Utils.approach(self.fade_rect.alpha, 1, DTMULT/20)
    end

    if not self.attacked then
        for index, bolt in ipairs(self.bolts) do
            bolt:move(-self.weapon:getBoltSpeed() * DTMULT, 0)
        end
    end

    if not Game.battle.cancel_attack and Input.pressed("confirm") then
        self.flash = 1
    else
        self.flash = Utils.approach(self.flash, 0, DTMULT/5)
    end

    super:update(self)
end

function MultiAttackBox:draw()
    local target_color = {self.battler.chara:getAttackBarColor()}
    local box_color = {self.battler.chara:getAttackBoxColor()}

    if self.flash > 0 then
        box_color = Utils.lerp(box_color, {1, 1, 1}, self.flash)
    end

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")

    love.graphics.setColor(box_color)
    love.graphics.rectangle("line", 80, 1, (15 * self.weapon:getBoltLeniency()) + 3, 36)
    love.graphics.setColor(target_color)
    love.graphics.rectangle("line", 83, 1, 8, 36)

    love.graphics.setLineWidth(1)

    super:draw(self)  
end

return MultiAttackBox