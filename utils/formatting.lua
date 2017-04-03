bgml.futils = {}

function bgml.futils.s(label, number, s)
    if number == 1 then
        return ("%d %s"):format(number, label)
    else
        return ("%d %s%s"):format(number, label, s or "s")
    end
end

if bgml.internal.config.futils_full then
    fS = bgml.futils.s
end
