local Lib = {}

function Lib:init()
    print("glhf")

    -- Item Hooks --

    Utils.hook(Item, "init", function(orig, self)

        orig(self)

        self.weapon_type = "bolt"
    
        self.bolt_count = 1 --might as well have the vanilla stuff be the default fn
        self.bolt_speed = 8
        self.bolt_leniency = 8
        self.bolt_offset = 8
        self.bolt_count_variance = 20
    
    end)

    Utils.hook(Item, "getWeaponType", function(orig, self)
        return self.weapon_type
    end)
    
    Utils.hook(Item, "getBoltCount", function(orig, self)
        return self.bolt_count
    end)

    Utils.hook(Item, "getBoltSpeed", function(orig, self)
        return self.bolt_speed
    end)
    
    Utils.hook(Item, "getBoltLeniency", function(orig, self)
        return self.bolt_leniency
    end)

    Utils.hook(Item, "getBoltOffset", function(orig, self)
        return self.bolt_offset
    end)

    Utils.hook(Item, "getBoltCountVariance", function(orig, self)
        return self.bolt_count_variance
    end)

    --## ATTACK BOX HOOKS ##--

--[[     Utils.hook(AttackBox, "init", function(orig, self, battler, offset, x, y)
        
        AttackBox.__super:init(self, x, y)
             
        self.battler = battler
        self.offset = offset
        self.weapon = battler.chara:getWeapon()

        self.head_sprite = Sprite(battler.chara:getHeadIcons().."/head", 21, 19)
        self.head_sprite:setOrigin(0.5, 0.5)
        self:addChild(self.head_sprite)

        self.press_sprite = Sprite("ui/battle/press", 42, 0)
        self:addChild(self.press_sprite)

        self.bolt_target = 80 + 2
        self.bolt_start_x = self.bolt_target + (self.offset * self.weapon:getBoltOffset()) --get leniency


        if self.weapon:getBoltCount() == 1 then
            
            self.bolt = AttackBar(self.bolt_start_x, 0, 6, 38)
            self.bolt.layer = 1
            self:addChild(self.bolt)

        else

            self.bolts = {}
            self.scores = {}
            self.result = 0

            for i = 1, self.weapon:getBoltCount() do

                local bolt = AttackBar(self.bolt_start_x + (i - 3) * self.weapon:getBoltCountVariance(), 0, 6, 38)
                bolt.layer = 1
                self.bolts[i] = bolt -- remember, you can use the counter variable in the statements for things like adding table entries
                self:addChild(bolt)

            end

        end

        self.fade_rect = Rectangle(0, 0, SCREEN_WIDTH, 38)
        self.fade_rect:setColor(0, 0, 0, 0)
        self.fade_rect.layer = 2
        self:addChild(self.fade_rect)

        self.afterimage_timer = 0
        self.afterimage_count = -1

        self.flash = 0

        self.attacked = false    
    end) ]]
    
--[[     Utils.hook(AttackBox, "getClose", function(orig, self)
        if self.weapon:getBoltCount() == 1 then
            return Utils.round((self.bolt.x - self.bolt_target) / self.weapon:getBoltLeniency())
        else
            return Utils.round((self.bolts[1].x - self.bolt_target) / self.weapon:getBoltLeniency())
        end
    end) ]]

--[[     Utils.hook(AttackBox, "hit", function(orig, self)
        if self.weapon:getBoltCount() == 1 then
            return orig(self)
        else

            local bolt = self.bolts[1]

            local score = math.abs(math.floor(self:getClose())) -- how close the bolt is to the target
            table.insert(self.scores, score)

            bolt:burst()
            bolt.layer = 1
            bolt:setPosition(bolt:getRelativePos(0, 0, self.parent))
            bolt:setParent(self.parent)
            
            table.remove(self.bolts, 1)
            if #self.bolts == 0 then
                
                for i = 1, self.weapon:getBoltCount() do
                    self.result = self.result + self.scores[1]
                    table.remove(self.scores, 1)
                end

                self.attacked = true
                print("final score: " .. self.result)
            end

            if self.result == 0 or self.result == 1 or self.result == 2 then -- crit
                bolt:setColor(1, 1, 0)
                bolt.burst_speed = 0.2
                Assets.stopAndPlaySound("perfect", 1)
                print(self.result)
                return 150
            elseif self.result == 3 or self.result == 4 then
                bolt:setColor(self.battler.chara:getDamageColor())
                Assets.stopAndPlaySound("hit", 1)
                print(self.result)
                return 120
            elseif self.result == 5 or self.result == 6 then
                bolt:setColor(self.battler.chara:getDamageColor())
                Assets.stopAndPlaySound("hit", 1)
                print(self.result)
                return 110
            elseif self.result >= 7 then
                --Assets.stopAndPlaySound("hit", 1)
                bolt:setColor(1, 80/255, 80/255, 1)
                print(self.result)
                return 100 - (self.result / 2)
            end


        end
    end) ]]

--[[     Utils.hook(AttackBox, "miss", function(orig, self)
        if self.weapon:getBoltCount() == 1 then
            orig(self)
        else
            self.bolts[1]:remove()
            table.remove(self.bolts, 1)

            if #self.bolts <= 0 then
                self.attacked = true
            end
        end
    end) ]]

--[[     Utils.hook(AttackBox, "update", function(orig, self)
        if self.weapon:getBoltCount() == 1 then
            orig(self)
        else

            if Game.battle.cancel_attack then
                self.fade_rect.alpha = Utils.approach(self.fade_rect.alpha, 1, DTMULT/20)
            end
        
            if not self.attacked then

                for index, bolt in ipairs(self.bolts) do
                    bolt:move(-self.weapon:getBoltSpeed() * DTMULT, 0)
                end
            end

        end

        AttackBox.__super:update(self)

    end) ]]

--[[     Utils.hook(AttackBox, "draw", function(orig, self)
    
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
    
        AttackBox.__super:draw(self)  

    end) ]]

--[[     Utils.hook(Battle, "processAction", function(orig, self, action)
    
        if action.action == "ATTACK" or action.action == "AUTOATTACK" then

            local battler = self.party[action.character_id]
            local enemy = action.target
        
            self.current_processing_action = action

            local attackbox
                for _,box in ipairs(Game.battle.battle_ui.attack_boxes) do
                    if box.battler == battler then
                        attackbox = box
                        break
                    end
                end
            
            self.weapon = battler.chara:getWeapon()

            if self.weapon:getWeaponType() == "multibolt" and #attackbox.bolts == 0 then
                action.points = action.points + attackbox.score

                local src = Assets.stopAndPlaySound(battler.chara:getAttackSound() or "laz_c")
                src:setPitch(battler.chara:getAttackPitch() or 1)
        
                self.actions_done_timer = 1.2
        
                local crit = action.points == 150 and action.action ~= "AUTOATTACK"
                if crit then
                    Assets.stopAndPlaySound("criticalswing")
        
                    for i = 1, 3 do
                        local sx, sy = battler:getRelativePos(battler.width, 0)
                        local sparkle = Sprite("effects/criticalswing/sparkle", sx + Utils.random(50), sy + 30 + Utils.random(30))
                        sparkle:play(4/30, true)
                        sparkle:setScale(2)
                        sparkle.layer = BATTLE_LAYERS["above_battlers"]
                        sparkle.physics.speed_x = Utils.random(2, 6)
                        sparkle.physics.friction = -0.25
                        sparkle:fadeOutAndRemove()
                        self:addChild(sparkle)
                    end
                end
        
                battler:setAnimation("battle/attack", function()
                    action.icon = nil
        
                    if action.target and action.target.done_state then
                        enemy = self:retargetEnemy()
                        action.target = enemy
                        if not enemy then
                            self.cancel_attack = true
                            self:finishAction(action)
                            return
                        end
                    end
        
                    local damage = Utils.round(enemy:getAttackDamage(action.damage or 0, battler, action.points or 0))
                    if damage < 0 then
                        damage = 0
                    end
        
                    if damage > 0 then
                        Game:giveTension(Utils.round(enemy:getAttackTension(action.points or 100)))
        
                        local dmg_sprite = Sprite(battler.chara:getAttackSprite() or "effects/attack/cut")
                        dmg_sprite:setOrigin(0.5, 0.5)
                        if crit then
                            dmg_sprite:setScale(2.5, 2.5)
                        else
                            dmg_sprite:setScale(2, 2)
                        end
                        dmg_sprite:setPosition(enemy:getRelativePos(enemy.width/2, enemy.height/2))
                        dmg_sprite.layer = enemy.layer + 0.01
                        dmg_sprite:play(1/15, false, function(s) s:remove() end)
                        enemy.parent:addChild(dmg_sprite)
        
                        Assets.stopAndPlaySound("damage")
                        enemy:hurt(damage, battler)
        
                        battler.chara:onAttackHit(enemy, damage)
                    else
                        enemy:statusMessage("msg", "miss", {battler.chara:getDamageColor()})
                    end
        
                    self:finishAction(action)
        
                    Utils.removeFromTable(self.normal_attackers, battler)
                    Utils.removeFromTable(self.auto_attackers, battler)
        
                    if not self:retargetEnemy() then
                        self.cancel_attack = true
                    elseif #self.normal_attackers == 0 and #self.auto_attackers > 0 then
                        local next_attacker = self.auto_attackers[1]
        
                        local next_action = self:getActionBy(next_attacker)
                        if next_action then
                            self:beginAction(next_action)
                            self:processAction(next_action)
                        end
                    end
                end)
            end
        else
            orig(self, action)
        end
    end) ]]

    Utils.hook(Battle, "processAction", function(orig, self, action)

        local battler = self.party[action.character_id]
        local party_member = battler.chara -- ???
        local enemy = action.target
        local battler_weapon = battler.chara:getWeapon()
    
        self.current_processing_action = action

        local attackbox
        for _,box in ipairs(Game.battle.battle_ui.attack_boxes) do
            if box.battler == battler then
                attackbox = box
                break
            end
        end

        if action.action == "ATTACK" or action.action == "AUTOATTACK" then
            if attackbox.attacked then
                local src = Assets.stopAndPlaySound(battler.chara:getAttackSound() or "laz_c")
                src:setPitch(battler.chara:getAttackPitch() or 1)
        
                self.actions_done_timer = 1.2
        
                local crit = action.points == 150 and action.action ~= "AUTOATTACK"
                if crit then
                    Assets.stopAndPlaySound("criticalswing")
        
                    for i = 1, 3 do
                        local sx, sy = battler:getRelativePos(battler.width, 0)
                        local sparkle = Sprite("effects/criticalswing/sparkle", sx + Utils.random(50), sy + 30 + Utils.random(30))
                        sparkle:play(4/30, true)
                        sparkle:setScale(2)
                        sparkle.layer = BATTLE_LAYERS["above_battlers"]
                        sparkle.physics.speed_x = Utils.random(2, 6)
                        sparkle.physics.friction = -0.25
                        sparkle:fadeOutSpeedAndRemove()
                        self:addChild(sparkle)
                    end
                end
        
                battler:setAnimation("battle/attack", function()
                    action.icon = nil
        
                    if action.target and action.target.done_state then
                        enemy = self:retargetEnemy()
                        action.target = enemy
                        if not enemy then
                            self.cancel_attack = true
                            self:finishAction(action)
                            return
                        end
                    end
        
                    local damage = Utils.round(enemy:getAttackDamage(action.damage or 0, battler, action.points or 0))
                    if damage < 0 then
                        damage = 0
                    end
        
                    if damage > 0 then
                        Game:giveTension(Utils.round(enemy:getAttackTension(action.points or 100)))
        
                        local dmg_sprite = Sprite(battler.chara:getAttackSprite() or "effects/attack/cut")
                        dmg_sprite:setOrigin(0.5, 0.5)
                        if crit then
                            dmg_sprite:setScale(2.5, 2.5)
                        else
                            dmg_sprite:setScale(2, 2)
                        end
                        dmg_sprite:setPosition(enemy:getRelativePos(enemy.width/2, enemy.height/2))
                        dmg_sprite.layer = enemy.layer + 0.01
                        dmg_sprite:play(1/15, false, function(s) s:remove() end)
                        enemy.parent:addChild(dmg_sprite)
        
                        local sound = enemy:getDamageSound() or "damage"
                        if sound and type(sound) == "string" then
                            Assets.stopAndPlaySound(sound)
                        end
                        enemy:hurt(damage, battler)
        
                        battler.chara:onAttackHit(enemy, damage)
                    else
                        enemy:statusMessage("msg", "miss", {battler.chara:getDamageColor()})
                    end
        
                    self:finishAction(action)
        
                    Utils.removeFromTable(self.normal_attackers, battler)
                    Utils.removeFromTable(self.auto_attackers, battler)
        
                    if not self:retargetEnemy() then
                        self.cancel_attack = true
                    elseif #self.normal_attackers == 0 and #self.auto_attackers > 0 then
                        local next_attacker = self.auto_attackers[1]
        
                        local next_action = self:getActionBy(next_attacker)
                        if next_action then
                            self:beginAction(next_action)
                            self:processAction(next_action)
                        end
                    end
                end)
            end
        elseif action.action == "SKIP" then
            return true -- has to be here to prevent multi-acts from softlocking, somehow they get caught on SKIP
        else
            orig(self, action)
        end
    end)

    Utils.hook(BattleUI, "beginAttack", function(orig, self)
        local attack_order = Utils.pickMultiple(Game.battle.normal_attackers, #Game.battle.normal_attackers)

        local last_offset = -1
        local offset = 0
        for i = 1, #attack_order do
            offset = offset + last_offset
    
            local battler = attack_order[i]
            if battler.chara:getWeapon():getWeaponType() == "multibolt" then
                local attack_box = MultiAttackBox(battler, 30 + offset, 0, 40 + (38 * (Game.battle:getPartyIndex(battler.chara.id) - 1)))
                self:addChild(attack_box)
                table.insert(self.attack_boxes, attack_box)
            else
                local attack_box = AttackBox(battler, 30 + offset, 0, 40 + (38 * (Game.battle:getPartyIndex(battler.chara.id) - 1)))
                self:addChild(attack_box)
                table.insert(self.attack_boxes, attack_box)
            end
    
            if i < #attack_order and last_offset ~= 0 then
                last_offset = Utils.pick{0, 10, 15}

            else
                last_offset = Utils.pick{10, 15}
            end

            print(battler.chara.name .. " is " .. offset + 1)

        end
    
        self.attacking = true
    end)

    Utils.hook(Battle, "updateAttacking", function(orig, self)

        if self.cancel_attack then
            self:finishAllActions()
            self:setState("ACTIONSDONE")
            return
        end

        if not self.attack_done then
            if not self.battle_ui.attacking then
                self.battle_ui:beginAttack()
            end

            if #self.attackers == #self.auto_attackers and self.auto_attack_timer < 4 then
                self.auto_attack_timer = self.auto_attack_timer + DTMULT

                if self.auto_attack_timer >= 4 then
                    local next_attacker = self.auto_attackers[1]

                    local next_action = self:getActionBy(next_attacker)
                    if next_action then
                        self:beginAction(next_action)
                        self:processAction(next_action)
                    end
                end
            end

            local all_done = true

            for _,attack in ipairs(self.battle_ui.attack_boxes) do
                if not attack.attacked and attack.fade_rect.alpha < 1 then
                    local close = attack:getClose()
                    if attack.battler.chara:getWeapon():getWeaponType() == "multibolt" then
                        if close <= -5 and #attack.bolts > 1 then

                            all_done = false
                            attack:miss()                            

                        elseif close <= -5 and #attack.bolts == 1 then
                            local points = attack:miss() -- lmao

                            local action = self:getActionBy(attack.battler)
                            action.points = points

                            if self:processAction(action) then
                                self:finishAction(action)
                            end
                        else
                            all_done = false
                        end
                    else
                        if close <= -5 then
                            attack:miss()

                            local action = self:getActionBy(attack.battler)
                            action.points = 0

                            if self:processAction(action) then
                                self:finishAction(action)
                            end
                        else
                            all_done = false
                        end
                    end
                end
            end

            if #self.auto_attackers > 0 then
                all_done = false
            end

            if all_done then
                self.attack_done = true
            end
        else
            if self:allActionsDone() then
                self:setState("ACTIONSDONE")
            end
        end
    end)

    Utils.hook(Battle, "drawDebug", function(orig, self)
        orig(self)

        local ui = self.battle_ui

        for i, battler in ipairs(self.party) do
            if battler.chara:getWeapon():getWeaponType() == "multibolt" then

                local perfect_score = (105 * battler.chara:getWeapon():getBoltCount())
                local crit = perfect_score - MultiAttackBox.CRITICAL
        
                if self.state == "ATTACKING" or self.state == "ACTIONSDONE" and ui.attack_boxes[i] then

                    if perfect_score - ui.attack_boxes[i].score <= MultiAttackBox.CRITICAL then
                        love.graphics.setColor(1, 1, 0, 1)
                    end

                    self:debugPrintOutline("how ourple " .. battler.chara.name .. " is: " .. ui.attack_boxes[i].score .. ", (" .. crit .. " for a crit)", 4, ui.attack_boxes[i].y + 310)
                end

            end
        end
        
    end)

end

return Lib