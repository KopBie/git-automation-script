#!/bin/bash
# Pindah ke direktori tempat skrip ini berada
cd "$(dirname "$0")"

# Warna untuk tampilan (Opsional)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

header() {
    clear
    echo "========================================="
    echo "    (GIT MANAGER) PUSH FILE KE GITHUB    "
    echo "========================================="
    if [ -d ".git" ]; then
        CURRENT_REPO=$(git remote get-url origin 2>/dev/null)
        BRANCH=$(git branch --show-current)
        echo -e "Repo Aktif : ${GREEN}${CURRENT_REPO:-Belum ada remote}${NC}"
        echo -e "Branch     : ${GREEN}${BRANCH}${NC}"
    else
        echo -e "Status     : ${RED}Belum ada Git di folder ini${NC}"
    fi
    echo "-----------------------------------------"
}

while true; do
    header
    echo "PILIH OPSI:"
    echo "1. Tautkan / Ganti Link Repo"
    echo "2. Push / Upload Tugas"
    echo "3. Hapus File / Folder di GitHub"
    echo "4. Keluar"
    echo "-----------------------------------------"
    read -p "Masukkan pilihan (1-4): " menu

    case $menu in
        1)
            header
            echo "--- PENGATURAN / GANTI REPOSITORI ---"
            read -p "Lanjutkan proses ini? (y/n): " confirm
            [[ "$confirm" != "y" ]] && continue

            if [ ! -d ".git" ]; then
                git init -q
                git branch -M main
            fi

            read -p "Masukkan URL Repository GitHub baru: " repo_url
            if [ -z "$repo_url" ]; then
                echo "URL kosong, kembali ke menu..."
            else
                git remote remove origin 2>/dev/null
                git remote add origin "$repo_url"
                
                # Cek apakah identitas git sudah diatur
                if [ -z "$(git config user.name)" ]; then
                    read -p "Masukkan Nama GitHub Anda: " gh_name
                    read -p "Masukkan Email GitHub Anda: " gh_email
                    git config user.name "$gh_name"
                    git config user.email "$gh_email"
                fi
                echo "Berhasil ditautkan!"
            fi
            sleep 1
            ;;

        2)
            header
            echo "--- PUSH / UPLOAD TUGAS ---"
            if [ ! -d ".git" ] || ! git remote | grep -q "origin"; then
                echo -e "${RED}ERROR: Folder belum tertaut ke Repo. Pilih Opsi 1 dulu.${NC}"
                read -p "Tekan [Enter] untuk kembali..."
                continue
            fi

            echo "Sinkronisasi dengan GitHub..."
            git pull origin $(git branch --show-current) --no-rebase 2>/dev/null
            
            git add .
            echo ""
            echo "--- DAFTAR FILE SIAP PUSH ---"
            git status --short
            echo "-----------------------------"
            read -p "Pesan commit (kosongkan untuk otomatis): " msg
            [ -z "$msg" ] && msg="Update tugas: $(date +'%d-%m-%Y %H:%M')"
            
            read -p "Kirim sekarang? [y/n]: " push_confirm
            if [[ "$push_confirm" == "n" ]]; then
                echo "Pengiriman dibatalkan."
            else
                git commit -m "$msg"
                if git push origin $(git branch --show-current); then
                    echo -e "${GREEN}BERHASIL: Tugas terkirim.${NC}"
                else
                    echo -e "${RED}GAGAL: Terjadi kesalahan saat push.${NC}"
                fi
            fi
            read -p "Tekan [Enter] untuk kembali..."
            ;;

        3)
            header
            echo "--- HAPUS FILE / FOLDER DI GITHUB ---"
            if [ ! -d ".git" ]; then
                echo -e "${RED}ERROR: Folder belum memiliki Git.${NC}"
                read -p "Tekan [Enter] untuk kembali..."
                continue
            fi

            echo "Sinkronisasi data terbaru..."
            git pull origin $(git branch --show-current) --no-rebase -q 2>/dev/null
            
            items=(*)
            echo "Daftar isi folder saat ini:"
            echo "0. [BATAL]"
            echo "A. [HAPUS SEMUA ISI REPO]"
            for i in "${!items[@]}"; do
                echo "$((i+1)). ${items[$i]}"
            done
            echo "-----------------------------------------"
            read -p "Pilih nomor atau ketik 'A' untuk semua: " choice
            
            if [[ "$choice" == "0" ]]; then
                continue
            elif [[ "$choice" == "A" || "$choice" == "a" ]]; then
                header
                echo "!!! PERINGATAN: HAPUS SEMUA ISI REPOSITORI !!!"
                echo "1. Hapus di GitHub Saja (File lokal aman)"
                echo "2. Hapus Total (File di folder ini juga hilang)"
                echo "0. Batal"
                read -p "Pilihan mode: " all_mode
                
                case $all_mode in
                    1)
                        git rm -r --cached .
                        git commit -m "Cleanup: Menghapus semua file dari GitHub"
                        git push origin $(git branch --show-current)
                        echo "GitHub berhasil dikosongkan."
                        ;;
                    2)
                        read -p "Anda yakin ingin menghapus SEMUA secara lokal & remote? (y/n): " final_confirm
                        if [[ "$final_confirm" == "y" ]]; then
                            git rm -rf .
                            git commit -m "Wipe: Menghapus seluruh isi repositori"
                            git push origin $(git branch --show-current)
                            echo "Seluruh file telah dihapus total."
                        else
                            echo "Dibatalkan."
                        fi
                        ;;
                    *) echo "Batal.";;
                esac
            elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#items[@]}" ]; then
                target="${items[$((choice-1))]}"
                echo "Target: $target"
                echo "Mode: 1. GitHub Saja | 2. Total | 0. Batal"
                read -p "Pilihan: " mode
                
                case $mode in
                    1)
                        git rm -r --cached "$target"
                        git commit -m "Hapus $target dari GitHub"
                        git push origin $(git branch --show-current)
                        echo "Berhasil dihapus dari GitHub."
                        ;;
                    2)
                        git rm -r "$target"
                        git commit -m "Hapus $target secara total"
                        git push origin $(git branch --show-current)
                        echo "Berhasil dihapus secara total."
                        ;;
                    *) echo "Batal.";;
                esac
            else
                echo "Pilihan tidak valid."
            fi
            read -p "Tekan [Enter] untuk kembali..."
            ;;

        4)
            header
            read -p "Yakin ingin keluar? (y/n): " exit_confirm
            if [[ "$exit_confirm" == "y" ]]; then
                echo "Keluar..."
                exit 0
            fi
            ;;

        *)
            echo "Pilihan tidak tersedia."
            sleep 1
            ;;
    esac
done