function intersections = fault_intersections(faults)

intersections = {};
for f1 = 1:numel(faults)
    % first find intersection between fault i and all other faults
    for f2 = f1+1:numel(faults)
       int_pts = polygon_intersection(faults{f1}, faults{f2});
       if size(int_pts, 1) > 0
           intersections= {intersections{:}, {int_pts, f1, f2}};
       end
    end
end

% then split intersection of intersections

for f = 1:numel(faults)
    f_pts = faults{f};
    center = mean(f_pts, 1);
    f_center = bsxfun(@minus, f_pts, center);
    R = rotation_matrix_from_plane(f_center);
    f_xy = f_center * R';
    assert(sum(abs(f_xy(:, 3)))<1e-6);
    f_xy = f_xy(:,1:2);
    internal_pts_xy = zeros(0, 2);
    int_in_plane = false(numel(intersections),1);
    for j = 1:numel(intersections)
        if intersections{j}{2}==f || intersections{j}{3}==f 
            int_in_plane(j) = true;
            pts_i = intersections{j}{1};
            pts_i_center = bsxfun(@minus, pts_i, center);
            pts_i_xy = pts_i_center * R';
            assert(all(abs(pts_i_xy(:,3))<1e-6))
            pts_i_xy = pts_i_xy(:, 1:2);
            assert(size(pts_i_xy,1)==2)
            internal_pts_xy = [internal_pts_xy; pts_i_xy];
        end
    end
    num_lines = size(internal_pts_xy,1)/2;
    internal_pts_xy = mat2cell(internal_pts_xy, 2 * ones(num_lines,1), 2)';
    [split_pts_xy, ~, ~, ic] = splitAtInt(internal_pts_xy, internal_pts_xy);
    %split_pts_xy = cell2mat(split_pts_xy)';
    split_pts = cellfun(@(c) [c, zeros(2, 1)], split_pts_xy, 'un',0);
    split_pts = cellfun(@(c) c * R + center, split_pts, 'un', 0);
    
    % remove old intersection lines and add new
    new_intersections = intersections(ic);
    new_intersections = cellfun(@(c1,c2) [c1, c2(2:3)], split_pts, new_intersections, 'un', 0);
    intersections = [intersections(~int_in_plane), new_intersections];


end
end