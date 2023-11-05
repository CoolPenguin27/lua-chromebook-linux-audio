--# a module script thats kinda like a port of the functions.py

--# By SuperPenguin34
local utils = {}

utils.distro = "unknown"
utils.distro_codename = "unknown"
utils.version_codename = "unknown"
utils.version_number = "unknown"

local distro_names = {
    ubuntu = "ubuntu",
    arch = "arch",
    fedora = "fedora",
    debian = "debian",
    void = "void",
    suse = "suse"
}

function utils:RunCommand(command, only_output)
--# stack overflow https://stackoverflow.com/questions/7607384/getting-return-status-and-program-output
    local handle = io.popen(command)
    --# get popen handle
    local output = handle:read("a")
    --# read the result
    local success = handle:close()
    --# close handle
    if only_output then
        return (tonumber(output) or tostring(output))
        else
        return success, (tonumber(output) or tostring(output))
    end
    --# easy way to remove those werid indents when getting the result
end

function utils:CleanString(string)
    --# i figured this out because my RunCommand(product_name) wasnt matching up with a board (and if sys_board == "delbin" didnt work)
    local new_string = string.gsub(string, "\n", "")
    new_string = string.gsub(new_string, " ", "")
    new_string = string.gsub(new_string, '"', "")
    new_string = string.gsub(new_string, ",", "")
    return new_string
end

function utils:read_file(string)
    --# opens said file and reads it
    local handle = io.open(string, "r")
    if not handle then
        utils:print_error("Error reading file: "..string)
        os.exit(false)
    end
    local result = handle:read("a")
    handle:close()
    return result
end

function utils:check_file_exists(string)
    --# checks if file/folder exists
    --# https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
    local success, error, code = os.rename(string, string)
    if not success then
        if code == 13 then
            --# permission only got denied, its there though
            return true
        end
    end
    return success
end

function utils:remove_folder(folder)
    --# removes file/folder
    local success = os.remove(folder)
    if not success then
        --# werid feeling this will cause a github issue
       return utils:RunCommand("rm -r "..folder)
       --# feel like something with /dev/null might screw something up
    end
    return true
end

function utils:write_file(file, string)
    --# opens said file and writes in it
    local handle = io.open(file, "w")
    if not handle then
        return false
    end
    local result = handle:write(string)
    handle:close()
    return true
end

function utils:copy_file(og_file, new_file)
    --# opens said file and reads it
    local old_text = utils:read_file(og_file)
    if not old_text then
        return false
    end

    utils:write_file(new_file, old_text)
    return true
end

function utils:copy_dir(og_dir, new_dir)
    --# opens said file and reads it
    if not utils:RunCommand("cp -r "..og_dir.." "..new_dir) then
        utils:print_error("Error copying "..og_dir.." to "..new_dir)
        os.exit(false)
    end
    return true
end

function utils:mk_dir(new_directory)
    --# opens said file and reads it
    local success = utils:RunCommand("mkdir -p "..new_directory)
    if not success then
        utils:print_error("Error making directory path "..new_directory.." exiting")
        os.exit(false)
    end
    return true
end

function utils:download_file(url, filename)
    --# opens said file and reads it
    if not utils:check_file_exists("/usr/bin/curl") then
        utils:print_error("curl not installed, stopping download")
        os.exit(false)
    end
    local success = utils:RunCommand("curl "..url.." --output "..filename)

    if not success then
        utils:print_error("Error Downloading file: "..filename..", exiting")
        os.exit(false)
    end
    return success
end

function utils:install_package(arch_package, deb_package, rpm_package, suse_package, void_package)
    local success = false
    if utils.distro == "arch" then
        success = utils:RunCommand("pacman -S --noconfirm --needed "..arch_package)

    elseif utils.distro == "void" then
        success = utils:RunCommand("xbps-install -y "..void_package)

    elseif utils.distro == "ubuntu" or utils.distro == "debian" then
        success = utils:RunCommand("apt-get install -y "..deb_package)

    elseif utils.distro == "suse" then
        success = utils:RunCommand("zypper --non-interactive install "..suse_package)

    elseif utils.distro == "fedora" then
        success = utils:RunCommand("dnf install -y "..rpm_package)
    else
        utils:print_warning("Unable to install package :"..arch_package.." due to unknown distro, please install it manually.")
    end

    return success
end

function utils:ask_question(question, answer_one, answer_two, case_sensitive)
    if answer_two == nil then
        answer_two = math.huge
        --# not there, make inputting it impossible
    end 

    while true do
        utils:print_question(question)

        local selection = io.read()

        if not case_sensitive then
            --# to protect the toasty speaker thing
            selection = string.lower(selection)
        end

        if selection == answer_one then
            return 1

        elseif selection == answer_two then
            return 2

            else

            utils:print_error("Invalid option: "..selection)

        end

    end
end

local function CacheDistro()
    --# we dont need to read os-release everytime
    --# hopefully this works
    local distro = string.lower(utils:read_file("/etc/os-release"))


    for line in io.lines("/etc/os-release") do
        --# going to need the codename later
        line = string.lower(line)


        --# we probably need these at some point in the future

        if string.find(line, "ubuntu_codename=") or string.find(line, "debian_codename=")  then
            if utils.version_codename ~= "unknown" then
                goto continue
            end
            local result = string.sub(line, (string.find(line, "=") + 1), string.len(line))
            utils.distro_codename = utils:CleanString(result)
        elseif string.find(line, "version_id=") then
            local result = string.sub(line, (string.find(line, "=") + 1), string.len(line))
            utils.version_number = tonumber(utils:CleanString(result))
        elseif string.find(line, "version_codename=") then
            local result = string.sub(line, (string.find(line, "=") + 1), string.len(line))
            utils.version_codename = utils:CleanString(result)
        elseif string.find(line, "id=") then
            local result = string.sub(line, (string.find(line, "=") + 1), string.len(line))
            result = utils:CleanString(result)
            if distro_names[result] ~= nil then
                utils.distro = result
            end
        elseif string.find(line, "id_like=") then
            if utils.distro == "unknown" then
                --# only if the distro wasnt found yet
                local result = string.sub(line, (string.find(line, "=") + 1), string.len(line))
                result = utils:CleanString(result)
                if distro_names[result] ~= nil then
                    utils.distro = result
                end
            end
        else
            goto continue
        end
        ::continue::
    end

end

--# the prints, ported from the original functions,py
function utils:print_status(string)
    print("\27[94m" .. string .. "\27[0m")
end

function utils:print_warning(string)
    print("\27[93m" .. string .. "\27[0m")
end

function utils:print_error(string)
    print("\27[91m" .. string .. "\27[0m")
end

function utils:print_question(string)
    print("\27[92m" .. string .. "\27[0m")
end

function utils:print_header(string)
    print("\27[95m" .. string .. "\27[0m")
end

CacheDistro()
return utils
