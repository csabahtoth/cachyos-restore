local function setup()
    local sorted = false
    ps.sub("ind-sort", function(opt)
        local cwd = cx.active.current.cwd
        if cwd:ends_with("Downloads") then
            if not sorted then
                sorted = true
                opt.by, opt.reverse, opt.dir_first = "mtime", true, false
            end
        else
            if sorted then
                sorted = false
                opt.by, opt.reverse, opt.dir_first = "natural", false, true
            end
        end
        return opt
    end)
end

return { setup = setup }
