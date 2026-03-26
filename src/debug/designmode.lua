local love = require("love")

local DesignMode = {}

DesignMode.new = function(game)
    return setmetatable({
        game = game,
        level_design_mode = DESIGNMODE,
        level_design_selected_index = 1,
    }, {__index = DesignMode})
end

function DesignMode:update(dt)
    self:_update_level_design_input(dt)
    self:_clamp_level_design_index()
end

function DesignMode:keypressed(key)
    if self.level_design_mode and DEBUGMODE then
        if key == 'space' then
            self.level_design_selected_index = self.level_design_selected_index + 1
            self:_clamp_level_design_index()
            self:_print_selected_entity("selected")
            return
        end
    end
end

function DesignMode:draw()
    if not self.level_design_mode then
        return
    end

    local selected = self:_get_level_design_entity()
    if selected then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.setLineWidth(6)
        love.graphics.rectangle(
            'line',
            selected.position.x - selected.size.x / 2,
            selected.position.y - selected.size.y / 2,
            selected.size.x,
            selected.size.y
        )

        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle('fill', 5, 80, 1050, 45)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(
            string.format(
                "Level Design: SPACE next entity | Hold Arrow keys to move (%d px/s) | index=%d/%d | %s (%.2f, %.2f)",
                LEVEL_DESIGN_MOVE_SPEED,
                self.level_design_selected_index,
                #self.game.entities,
                selected.name or "Entity",
                selected.position.x,
                selected.position.y
            ),
            10,
            88
        )
    end

    for i, entity in ipairs(self.game.entities) do
        if entity ~= selected then
            love.graphics.setColor(1, 1, 0, 0.2)
            love.graphics.rectangle(
                'line',
                entity.position.x - entity.size.x / 2,
                entity.position.y - entity.size.y / 2,
                entity.size.x,
                entity.size.y
            )
        end
    end

end

function DesignMode:_clamp_level_design_index()
    if #self.game.entities == 0 then
        self.level_design_selected_index = 1
        return
    end

    if self.level_design_selected_index < 1 then
        self.level_design_selected_index = #self.game.entities
    elseif self.level_design_selected_index > #self.game.entities then
        self.level_design_selected_index = 1
    end
end

function DesignMode:_get_level_design_entity()
    self:_clamp_level_design_index()
    return self.game.entities[self.level_design_selected_index]
end

function DesignMode:_set_entity_position(entity, x, y)
    entity.position.x = x
    entity.position.y = y

    if entity.body then
        entity.body:setPosition(x, y)
        entity.body:setLinearVelocity(0, 0)
    end
end

function DesignMode:_print_selected_entity(reason)
    local entity = self:_get_level_design_entity()
    if not entity then
        print("[LevelDesign] self.game.entities is empty")
        return
    end

    print(string.format(
        "[LevelDesign] %s | index=%d/%d name=%s position=(%.2f, %.2f)",
        reason,
        self.level_design_selected_index,
        #self.game.entities,
        entity.name or "Entity",
        entity.position.x,
        entity.position.y
    ))
end

function DesignMode:_move_selected_entity(dx, dy)
    local entity = self:_get_level_design_entity()
    if not entity then
        return
    end

    local x = entity.position.x + math.floor(dx)
    local y = entity.position.y + math.floor(dy)
    self:_set_entity_position(entity, x, y)
    self:_print_selected_entity("moved")
end

function DesignMode:_update_level_design_input(dt)
    if not (self.level_design_mode and DEBUGMODE) then
        return
    end

    local x_axis = 0
    local y_axis = 0

    if love.keyboard.isDown('left') then
        x_axis = x_axis - 1
    end
    if love.keyboard.isDown('right') then
        x_axis = x_axis + 1
    end
    if love.keyboard.isDown('up') then
        y_axis = y_axis - 1
    end
    if love.keyboard.isDown('down') then
        y_axis = y_axis + 1
    end

    if x_axis == 0 and y_axis == 0 then
        return
    end

    local len = math.sqrt(x_axis * x_axis + y_axis * y_axis)
    if len > 0 then
        x_axis = x_axis / len
        y_axis = y_axis / len
    end

    self:_move_selected_entity(
        x_axis * LEVEL_DESIGN_MOVE_SPEED * dt,
        y_axis * LEVEL_DESIGN_MOVE_SPEED * dt
    )
end

return DesignMode