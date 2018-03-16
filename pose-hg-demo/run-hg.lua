-- Generate heatmaps for all images in a folder 
-- The heatmaps are saved as hdf5 files in the same folder
-- routine: th run-hg.lua FolderName ImageFilenameExtension
-- example: th run-hg.lua ../data/tennis jpg 

require 'paths'
paths.dofile('util.lua')
paths.dofile('img.lua')

local imgdir = arg[1]
local ext = arg[2]

model = torch.load('umich-stacked-hourglass.t7')   -- Load pre-trained model

for file in paths.files(imgdir) do
    if file:find(ext .. '$') then
        local name = paths.concat(imgdir,file)
        local img = image.load(name)
        local center = torch.Tensor(2)
        center[1] = img:size(3)/2
        center[2] = img:size(2)/2
        local scale = img:size(2) / 200
        local savefile = name:gsub(ext,'h5')

        local inp = crop(img,center,scale,0,256)
        local out = model:forward(inp:view(1,3,256,256):cuda())
        local hm = out[2][1]:float()
        hm[hm:lt(0)] = 0

        local predFile = hdf5.open(savefile,'w')
        predFile:write('heatmap',hm)
        predFile:close()

        print(savefile)

    end
end
