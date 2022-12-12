function output=fisher_information(rou,operator)
    [eigenstate,eigenvalue]=eig(rou);
    dim=size(rou);dim=dim(1);
    output=0;
    for i=1:dim
        lambda(i)=eigenvalue(i,i);
    end
    for i=1:dim
        for j=1:dim
            if lambda(i) + lambda(j) ~= 0
                addition=2*(lambda(i)-lambda(j))^2/(lambda(i)+lambda(j))*(abs(eigenstate(:,i)'*operator*eigenstate(:,j)))^2;
            else
                addition=0;
            end
            output=output+addition;
        end
    end
end