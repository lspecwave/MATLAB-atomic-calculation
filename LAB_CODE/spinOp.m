% Function to output the matrices of cartesian and ladder operators of
% spins.
% 
% spinOp(spin_number_array, component_array)
% 
% 'spin_number_array' defines spin quantum number S of spins. Number of
% elements defines the number of spins. If number of elements is one,
% number of elements is defined by number of elements in component_array.
%
% 'component_array' defines the cartesian(x,y,z)/ladder(p,m)/identity(e) components for
% each spin. The first element can optionally be '+' or '-' corresponding
% to the sign of the entire matrix.
% 
% valid examples:
% spinOp(1, 'x')
% spinOp(1/2, 'yz')
% spinOp([1/2 1 3/2], 'exz')
%
% rshankar.palani@gmail.com

function [mat] = spinOp(spin, code)
    if isnumeric(spin)==0, error('spin number (input 1) has to be an integer/half-integer greater than or equal to 1/2'); end
    if any(spin <= 0), error('spin number (input 1) has to be an integer greater than or equal to 1/2'); end
    if sum(mod(spin, 0.5)), error('spin number (input 1) can ONLY be an integer/half-integer'); end
    
    if isempty(code), mat = []; return; end
    
    N = numel(code);
    negTrue = 0;
    if code(1) == '-'
        negTrue = 1; code(1) = []; N = N-1;
    elseif code(1) == '+'
        code(1) = []; N = N-1;
    end
    
    if numel(spin) == 1
        spin = repmat(spin, [1, numel(code)]);
    elseif numel(spin) > numel(code)
        error('spin number array larger than component array');
    elseif numel(spin) < numel(code)
        error('spin number array smaller than component array');
    end
    
    for n = 1:N
        currentMat = zeros(2*spin(n)+1);
        mList = spin(n):-1:-spin(n);
        switch lower(code(n))
            case 'x'
                for ix1 = 1:2*spin(n)+1
                    for ix2 = 1:2*spin(n)+1
                        currentMat(ix1,ix2) = ...
                            (eq(mList(ix1), mList(ix2)+1) + eq(mList(ix1)+1, mList(ix2))) * ...
                            0.5 * sqrt(spin(n)*(spin(n)+1) - mList(ix1)*mList(ix2));
                    end
                end

            case 'y'
                for ix1 = 1:2*spin(n)+1
                    for ix2 = 1:2*spin(n)+1
                        currentMat(ix1,ix2) = ...
                            (eq(mList(ix1), mList(ix2)+1) - eq(mList(ix1)+1, mList(ix2))) * ...
                            -0.5i * sqrt(spin(n)*(spin(n)+1) - mList(ix1)*mList(ix2));
                    end
                end

            case 'z'
                for ix1 = 1:2*spin(n)+1
                    for ix2 = 1:2*spin(n)+1
                        currentMat(ix1,ix2) = eq(mList(ix1), mList(ix2)) * mList(ix2);
                    end
                end

            case 'p'
                for ix1 = 1:2*spin(n)+1
                    for ix2 = 1:2*spin(n)+1
                        currentMat(ix1,ix2) = ...
                            eq(mList(ix1), mList(ix2)+1) * ...
                            sqrt(spin(n)*(spin(n)+1) - mList(ix1)*mList(ix2));
                    end
                end

            case 'm'
                for ix1 = 1:2*spin(n)+1
                    for ix2 = 1:2*spin(n)+1
                        currentMat(ix1,ix2) = ...
                            eq(mList(ix1)+1, mList(ix2)) * ...
                            sqrt(spin(n)*(spin(n)+1) - mList(ix1)*mList(ix2));
                    end
                end

            case 'e'
                for ix1 = 1:2*spin(n)+1
                    for ix2 = 1:2*spin(n)+1
                        currentMat(ix1,ix2) = eq(mList(ix1), mList(ix2));
                    end
                end

            otherwise
                error('invalid operator in component array');
        end
        
        if n == 1, mat = currentMat;
        else, mat = kron(mat, currentMat);
        end
    end
    
    if negTrue == 1, mat = -1*mat; end
end