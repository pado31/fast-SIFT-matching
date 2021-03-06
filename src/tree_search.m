% Searching parallel hierarchical clustering trees
% Input: hierarchical clustering trees Ti, query point Q, K
% Output: K nearest approximate neighbors of query point
% Parameters: max number of points to examine Lmax

function neighbors = tree_search(T, Q, K, Lmax)
    L = 0; % number of point searched
    PQ = PriorityQueue(); % empty priority queue
    R = PriorityQueue(); % empty priority queue
    
    [PQ, R, l] = traverse_tree(T.root, PQ, R, Q);
    L = L + l;
    
    while PQ.size() ~= 0 && L < Lmax
        [N, pri] = PQ.pop();
        [PQ, R, l] = traverse_tree(N, PQ, R, Q);
        L = L + l;
    end
    
    neighbors = [];
    for i = 1 : K%min([K R.size()])
        [N, pri] = R.pop();
        neighbors = [neighbors; N];
    end
    
end




function [pq, r, l] = traverse_tree(N, PQ, R, Q)

    pq = PQ;
    r = R;
    l = 0;

    if size(N.children) == 0
        for i = 1: size(N.descriptor_set, 1)
            r.push(norm(N.descriptor_set(i).val - Q.val), N.descriptor_set(i));
            l = l + 1;
        end
        return;
    else
        C = N.children;
        % get closest node of C to query Q
        min = 1;
        for i = 2 : size(C)
           if norm(C(i).value.val - Q.val) < norm(C(min).value.val - Q.val)
               min = i;
           end
        end
        Cq = C(min);
        % all other nodes
        Cp = C(1:size(C, 1) ~= min);
        % add all nodes in Cp to PQ
        for i = 1 : size(Cp, 1)
            pq.push(norm(Cp(i).value.val - Q.val), Cp(i)); 
        end
        
        [pq, r, l1] = traverse_tree(Cq, pq, r, Q);
        l = l + l1;
        
    end

end