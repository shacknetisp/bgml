bgml.utils = {}

function bgml.utils.uid(segments, digits, delimiter)
    local segments = segments or 4
    local digits = digits or 4
    local delimiter = delimiter or '-'
    if segments < 1 then
        error("segments < 1")
    end
    if digits < 1 then
        error("digits < 1")
    end
    local maxval = math.pow(16, digits)
    local ret = {}
    for i=1,segments do
        table.insert(ret, ("%0"..tostring(digits).."X"):format(math.random(1, maxval)))
    end
    return table.concat(ret, delimiter)
end
