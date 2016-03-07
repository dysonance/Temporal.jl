using Temporal

function tsread(source::ByteString; dlm::Char=',', header::Bool=true, options...)
    data = readdlm(source, dlm, header=header, options...)
    if header == true
        fields = ByteString[string(fld) for fld=data[2]]
        index = Date[Date(d) for d=data[1][:,1]]
        body = data[1][:,2:end]
    elseif header == false
        fields = ByteString[string(fld) for fld=data[1,:]]
        index = Date[Date(d) for d=data[2:end,1]]
        body = data[2:end,2:end]
    end
    # Fill numerical data
    n = size(body,1)
    k = size(body,2)
    vals = zeros(n,k)
    for j=1:k
        for i=1:n
            try
                vals[i,j] = float(body[i,j])
            catch
                vals[i,j] = NaN
            end
        end
    end
    return ts(vals, index, fields[2:end])
end
