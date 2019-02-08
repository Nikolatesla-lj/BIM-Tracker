function [predicted_distances, reuse, t_reuse, angles_reuse,...
Q_delX_reuse, correspondence_final_unique]=temporal_reuse...
(correspondences_reuse,R_final,t_final, edgeim, dist_best_set,...
angles_final, Q_delX_reuse, visible_edges,  minlinelength, search_len,...
seglinelength, IRx, IRy, IPPM, f, search_len_short, ReuseFactor)
corr_mult=create_correspondences_multiple(visible_edges, R_final,...
    t_final, edgeim,  minlinelength, search_len, seglinelength,...
    IRx, IRy, IPPM, f);
corr_multi_length = length(corr_mult(:,1));
corr_single_length = length (correspondences_reuse(:,1));
samp_points_2d = world_to_pixel(f,correspondences_reuse(:,3:5),R_final,...
    t_final, IRx, IRy, IPPM);

t_reuse = [];
angles_reuse = [];
predicted_distances = [];
distances = [];
correspondence_final_unique = [];
%%
if corr_single_length > corr_multi_length*ReuseFactor
    h=1;

    for m = 1: length(samp_points_2d)
        if samp_points_2d(m,1)<IRx+1 && samp_points_2d(m,1)>0 &&...
                samp_points_2d(m,2)<IRy+1 && samp_points_2d(m,2)>0
            for len=0:search_len_short-1
                x1=samp_points_2d(m,1)+len/(sqrt((-1/...
                    correspondences_reuse(m,6))^2+1));
                x2=samp_points_2d(m,1)-len/(sqrt((-1/...
                    correspondences_reuse(m,6))^2+1));
                y1=(-1/correspondences_reuse(m,6))*...
                    (x1-samp_points_2d(m,1))+samp_points_2d(m,2);
                y2=(-1/correspondences_reuse(m,6))*...
                    (x2-samp_points_2d(m,1))+samp_points_2d(m,2);
                
                search_end_points(len+1,:)=round([x1 y1 x2 y2]);
                
                if search_end_points(len+1,1)<IRx+1 && search_end_points...
                        (len+1,1)>0 && search_end_points(len+1,2)...
                        <IRy+1 && search_end_points(len+1,2)>0
                if edgeim(search_end_points(len+1,2),...
                        search_end_points(len+1,1))
                   correspondence_final(h,:)=[search_end_points(len+1,1)...
                        search_end_points(len+1,2) ...
                    correspondences_reuse(m,3:6)];
                    test_final(h,:)=[search_end_points(len+1,1)...
                        search_end_points(len+1,2) ...
                        samp_points_2d(m,:) correspondences_reuse(m,3:5)];
                    distances(h) = dist_best_set (m);
                    h=h+1;
                    break; 
                end
                end
                if search_end_points(len+1,3)<IRx+1 && search_end_points...
                        (len+1,3)>0 && search_end_points(len+1,4)...
                        <IRy+1 &&  search_end_points(len+1,4)>0
                if edgeim(search_end_points(len+1,4), ...
                        search_end_points(len+1,3))
                   correspondence_final(h,:)=[search_end_points(len+1,3)...
                        search_end_points(len+1,4) ...
                    correspondences_reuse(m,3:6)];
                    test_final(h,:)=[search_end_points(len+1,3)...
                        search_end_points(len+1,4) ...
                        samp_points_2d(m,:) correspondences_reuse(m,3:5)];
                    distances(h) = dist_best_set (m);
                    h=h+1;
                    break; 
                end
                end
            end
        end
    end
    
    %%
    correspondence_final_unique=([correspondence_final(:,1:6)...
        test_final(:,1:4)]);
    differences = [correspondence_final_unique(:,1),...
    correspondence_final_unique(:,2)] -...
    [correspondence_final_unique(:,9), correspondence_final_unique(:,10)];
    predicted_distances = sqrt(differences(:,1).^2 + differences(:,2).^2);
    % convert to image coordinate from pixel coordinate
    correspondence_final_unique(:,1) =...
    ((correspondence_final_unique(:,1)-IRx/2)/IPPM); 
    correspondence_final_unique(:,2) =...
    ((IRy/2 -correspondence_final_unique(:,2))/IPPM);
    [~,t_reuse, angles_reuse, Q_delX_reuse] =...
        EstimatePoseKalman(correspondence_final_unique(:,1:2),...
        correspondence_final_unique(:,3:5), [angles_final(1)...
        angles_final(2) angles_final(3)], t_final, f);
    reuse = 1;
else
    reuse = 0;
end
end