function normOfArray = norm01(array)
% NORM01 is used to normalize an array to 0 and 1
% input£º
%       array: 1-D array needed to be normalized
% output£º
%       array: 1-D array normalized to 0 and 1
% programmed by Shijie Tu
% May, 28, 2019



if array == 0
   normOfArray = array;
else
%     minValue = min(array(:));
    maxValue = max(array(:));
    
    normOfArray = array ./maxValue;

end