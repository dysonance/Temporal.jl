using Temporal

function tsread(source::ByteString; dlm::Char=',', header::Bool=true, indextype::Type=Date,
                indexcol::Int=1, format::ByteString="yyyy-mm-dd", options...)
    if indextype != Date && indextype != DateTime
        error("Argument `indextype` must be either `Date` or `DateTime`.")
    end
    data = readdlm(source, dlm, header=header, options...)
    if header == true
        fields = ByteString[string(fld) for fld=data[2]]
        if indextype == Date
            index = Date[Date(d, format) for d=data[1][:,indexcol]]
        elseif indextype == DateTime
            index = DateTime[DateTime(d, format) for d=data[1][:,indexcol]]
        end
        body = data[1][:, 1:end .!= indexcol]
    elseif header == false
        fields = ByteString[string(fld) for fld=data[1,:]]
        if indextype == Date
            index = Date[Date(d, format) for d=data[2:end,indexcol]]
        elseif indextype == DateTime
            index = DateTime[DateTime(d, format) for d=data[2:end,indexcol]]
        end
        body = data[2:end, 1:end .!= indexcol]
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
