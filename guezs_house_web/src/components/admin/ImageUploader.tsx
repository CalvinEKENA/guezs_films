"use client";
import { useCallback, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { storage } from '@/lib/firebase';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';

export default function ImageUploader({ onUploadComplete }: { onUploadComplete: (url: string) => void }) {
  const [uploading, setUploading] = useState(false);

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (!file) return;

    setUploading(true);
    const storageRef = ref(storage, `products/${Date.now()}_${file.name}`);

    try {
      await uploadBytes(storageRef, file);
      const url = await getDownloadURL(storageRef);
      onUploadComplete(url);
      alert("Image téléchargée avec succès !");
    } catch (error) {
      console.error("Erreur d'upload:", error);
    } finally {
      setUploading(false);
    }
  }, [onUploadComplete]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({ onDrop });

  return (
    <div {...getRootProps()} className={`border-2 border-dashed p-10 text-center cursor-pointer transition-colors ${isDragActive ? 'border-guezs-gold bg-guezs-gold/10' : 'border-gray-300'}`}>
      <input {...getInputProps()} />
      {uploading ? (
        <p className="text-sm font-bold animate-pulse uppercase">Téléchargement en cours...</p>
      ) : (
        <p className="text-sm text-gray-500 uppercase tracking-widest">
          {isDragActive ? "Lâchez l'image ici" : "Glisser-déposer une photo de produit ici"}
        </p>
      )}
    </div>
  );
}