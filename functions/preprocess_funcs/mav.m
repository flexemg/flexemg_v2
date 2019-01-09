function [out] = mav(data)
    data = detrend(data);
    out = sum(abs(data))/length(data);
end