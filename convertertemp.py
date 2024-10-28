import os
import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
from tkinter.filedialog import askopenfilename
from tkinter.filedialog import askdirectory
import torch
from TTS.api import TTS
from pathlib import Path

device = "cuda" if torch.cuda.is_available() else "cpu"
print(device)
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2").to(device)
if input("Graphic(G) or TUI(T)") == "G":
    sample = askopenfilename()
    filename = askopenfilename() # show an "Open" dialog box and return the path to the selected file
    foldername = askdirectory()
else:
    sample = input("sampe:")
    filename = input("epub:") # show an "Open" dialog box and return the path to the selected file
    foldername = input("dir:")

newfolder = os.path.join(foldername, os.path.basename(os.path.splitext(filename)[0]))

def epub_to_txt_chapters(epub_file, output_dir):
    # Load the EPUB file
    book = epub.read_epub(epub_file)

    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Extract chapters
    for item in book.get_items():
        if item.get_type() == ebooklib.ITEM_DOCUMENT:
            soup = BeautifulSoup(item.get_body_content(), 'html.parser')
            title = soup.find('h1') or soup.find('h2')  # Attempt to find a title
            title_text = title.get_text(strip=True) if title else f'Chapter {item.get_id()}'
            filename = os.path.join(output_dir, f'{title_text}.txt')
            if not os.path.exists(filename):
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(soup.get_text())

    print(f'Converted {epub_file} into TXT chapters in {output_dir}.')
#txt = Path('data.txt').read_text()
# Example usage
epub_to_txt_chapters(filename, newfolder)
audiopath=newfolder+'audio'
if not os.path.exists(audiopath):
    os.makedirs(audiopath)
pathlist = Path(newfolder).rglob('*.txt')
for path in pathlist:
    path_in_str = str(path)
    # because path is object not string
    if not os.path.exists(os.path.join(audiopath, os.path.basename(os.path.splitext(path_in_str)[0]))+'.wav'):
        txt = Path(path).read_text()
        txt = txt.replace(u'\xa0', u' ')
        tts.tts_to_file(text=txt, speaker_wav=sample, language="en", file_path=(os.path.join(audiopath, os.path.basename(os.path.splitext(path_in_str)[0]))+'.wav'))
