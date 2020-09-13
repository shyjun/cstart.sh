
show_usage () {
    echo
    echo
    echo "Usage:"
    echo " -a <file/folder> : add files or folders to project list"
    echo " -c               : Continue even if any of files mentioned in -a is not available"
    echo " -k               : dont delete db"
    echo " -fl <listfile>   : use this list of files"
    echo " -d               : dont consider files in current path"
    echo
    echo
    exit
}

date

more_files=0
retain_db=0
fl_specified=0
not_present_continue=0
dont_consider_current_path_files=0
rm -f more_files_list
rm -f more_tree

delete_tag_list.sh

while [ "$#" -gt 0 ]; do
    case $1 in
        -fl) fl_specified=1
            echo "-fl"
            shift
            list_file=`realpath $1`
            echo db file fullpath=$fullpath
            if [ -f "$list_file" ]; then
                echo "$list_file exists."
            else 
                echo "$fullpath is a file.. Doesn't exist.. FAIL..."
                show_usage
            fi
            ;;
        -c) not_present_continue=1
            echo "-c"
            shift
            ;;
        -d) dont_consider_current_path_files=1
            echo "-d"
            shift
            ;;
        -k) retain_db=1
            echo "-k"
            shift
            ;;
        -a) more_files=1
            echo "-a"
            shift 
            newpath=$1
            fullpath=`realpath $1`
            echo fullpath=$fullpath

            echo "" >> more_tree

            if [ -d "$fullpath" ]; then
                echo "$fullpath is a directory."
                find $fullpath -name '*.[ch]'  >> more_files_list
                tree -aFf $fullpath | cat -n | grep -v ".*\.o" | grep -v ".*\.d" | grep -v ".*\.i" >> more_tree
            else
                echo "$fullpath is not a directory."
                if [ -f "$fullpath" ]; then
                    echo "$fullpath is a file. exists."
                    echo $fullpath >> more_files_list
                    echo $fullpath >> more_tree
                else 
                    echo "$fullpath Doesn't exist.."
                    if [[ $not_present_continue == 1 ]]; then
                        echo "-c set. skipping and continuing"
                    else
                        show_usage
                    fi
                fi
            fi
            shift
            ;;
        *)
            echo $1
            show_usage
            break
    esac
done

set -x

touch cscope.files

if [[ $dont_consider_current_path_files == 1 ]]; then
    echo "Not considering current directory files for tags"
else
    echo "Generating source file list..."
    find ./ -name "*.c" -o -name "*.h" -o -name "*.cc" -o -name "*.cpp"  -o -name "*.hh" -o -name "*.s"  -o -name "*.S"  | grep -v ".*NO_TAG" >> cscope.files
fi

if [[ $fl_specified == 1 ]]; then
    echo "file list already specified. using it..."
    cat $list_file >> cscope.files
fi

if [[ $more_files == 1 ]]; then
    echo "Appending more files..."
    cat more_files_list >> cscope.files
    rm -f more_files_list
fi

echo "Generating tags using ctags..."
ctags -L cscope.files

touch tree

if [[ $dont_consider_current_path_files == 1 ]]; then
    echo "Not considering current directory files for tree"
else
    echo "Adding current fdirectory files to tree..."
    #tree -aF ../ >> tree
    tree -aFf ./ | cat -n | grep -v ".*\.o" | grep -v ".*\.d" | grep -v ".*\.i" >> tree
fi

if [[ $fl_specified == 1 ]]; then
    cat $list_file >> tree
fi

if [[ $more_files == 1 ]]; then
    cat more_tree >> tree
    rm -f more_tree
fi

echo "Starting cscope..."
cscope -k -v -i cscope.files

if [[ $retain_db == 0 ]]; then
    delete_tag_list.sh
fi

