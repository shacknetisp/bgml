bgml.futils = {}

function bgml.futils.s(label, number, s)
    if number == 1 then
        return ("%d %s"):format(number, label)
    else
        return ("%d %s"):format(number, label, s or (label .. "s"))
    end
end
