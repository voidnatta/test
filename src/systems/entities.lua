local entities = {}
entities.queue_free_list = {}
entities.world = nil
entities.game = nil

entities.new = function(game, world)
    return setmetatable({
        game = game,
        world = world,
    }, {__index = entities})
end

entities.add_entity = function(self, entity)
    table.insert(self, entity)
    entity:load({world = self.world, entities = self, game = self.game})
end

entities.add_to_queue_free_list = function(self, entity)
    table.insert(self.queue_free_list, entity)
end

entities.queue_free_list_update = function(self)
    if #self.queue_free_list == 0 then
        return
    end

    -- destroy queued entities first, then remove from active list
    for _, qe in ipairs(self.queue_free_list) do
        if qe.destroy then
            qe:destroy()
        end

        for i, e in ipairs(self) do
            if e == qe then
                table.remove(self, i)
                break
            end
        end
    end

    -- clear the queue
    self.queue_free_list = {}
end

return entities