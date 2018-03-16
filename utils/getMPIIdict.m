function mpiidict = getMPIIdict(dict,source)

% create dictionary for mpii human pose dataset from other 3D datasets

switch lower(source)
    case 'hm36m'
        ind_new = 1:16;
        ind_old = [7,6,5,2,3,4,1,9,10,11,17,16,15,12,13,14];
        mpiidict.B(:,ind_new) = dict.B(:,ind_old);
        mpiidict.mu(:,ind_new) = dict.mu(:,ind_old);
    case 'cmu'
        ind_new = [1:8,10:16];
        ind_old = [7,6,5,2,3,4,1,8,9,15,14,13,10,11,12];
        mpiidict.B(:,ind_new) = dict.B(:,ind_old);
        mpiidict.mu(:,ind_new) = dict.mu(:,ind_old);
        % interpolate the location of neck = 1/3*head + 2/3*thorax
        mpiidict.B(:,9) = mpiidict.B(:,8)*2/3 + mpiidict.B(:,10)*1/3;
        mpiidict.mu(:,9) = mpiidict.mu(:,8)*2/3 + mpiidict.mu(:,10)*1/3;
    otherwise
        error('Unknown source of 3D data!');
end

mpiidict.skel.tree(1).name = ['RAnk'];
mpiidict.skel.tree(2).name = ['RKne'];
mpiidict.skel.tree(3).name = ['RHip'];
mpiidict.skel.tree(4).name = ['LHip'];
mpiidict.skel.tree(5).name = ['LKne'];
mpiidict.skel.tree(6).name = ['LAnk'];
mpiidict.skel.tree(7).name = ['Pelv'];
mpiidict.skel.tree(8).name = ['Thrx'];
mpiidict.skel.tree(9).name = ['Neck'];
mpiidict.skel.tree(10).name = ['Head'];
mpiidict.skel.tree(11).name = ['RWri'];
mpiidict.skel.tree(12).name = ['RElb'];
mpiidict.skel.tree(13).name = ['RSho'];
mpiidict.skel.tree(14).name = ['LSho'];
mpiidict.skel.tree(15).name = ['LElb'];
mpiidict.skel.tree(16).name = ['LWri'];

mpiidict.skel.tree(1).children = [];
mpiidict.skel.tree(2).children = [1];
mpiidict.skel.tree(3).children = [2];
mpiidict.skel.tree(4).children = [5];
mpiidict.skel.tree(5).children = [6];
mpiidict.skel.tree(6).children = [];
mpiidict.skel.tree(7).children = [3,4,8];
mpiidict.skel.tree(8).children = [9,13,14];
mpiidict.skel.tree(9).children = [10];
mpiidict.skel.tree(10).children = [];
mpiidict.skel.tree(11).children = [];
mpiidict.skel.tree(12).children = [11];
mpiidict.skel.tree(13).children = [12];
mpiidict.skel.tree(14).children = [15];
mpiidict.skel.tree(15).children = [16];
mpiidict.skel.tree(16).children = [];

mpiidict.skel.tree(1).color = ['g'];
mpiidict.skel.tree(2).color = ['g'];
mpiidict.skel.tree(3).color = ['g'];
mpiidict.skel.tree(4).color = ['r'];
mpiidict.skel.tree(5).color = ['r'];
mpiidict.skel.tree(6).color = ['r'];
mpiidict.skel.tree(7).color = ['b'];
mpiidict.skel.tree(8).color = ['b'];
mpiidict.skel.tree(9).color = ['b'];
mpiidict.skel.tree(10).color = ['b'];
mpiidict.skel.tree(11).color = ['g'];
mpiidict.skel.tree(12).color = ['g'];
mpiidict.skel.tree(13).color = ['g'];
mpiidict.skel.tree(14).color = ['r'];
mpiidict.skel.tree(15).color = ['r'];
mpiidict.skel.tree(16).color = ['r'];

mpiidict.skel.torso = [3,4,7,8,13,14];
