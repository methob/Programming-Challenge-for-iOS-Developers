
import UIKit
import SDWebImage
import IJProgressView

class MediaViewController: BaseViewController {

    var baseAssets: String = ""
    var medias: [Media] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.startActivityIndicator()
        MediaFilesService(delegate: self).requestMediaFiles()
        
        tableView.register(UINib(nibName: "MediaFilesTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaFileCell")
        
        mediaDelegate = self
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}

// MARK: - MediaFilesServiceDelegate
extension MediaViewController: MediaFilesServiceDelegate {
    
    func requestMediaFilesSuccessful(dataAssets: DataAssets?) {
        
        baseAssets = (dataAssets?.assetsLocation)!
        medias = (dataAssets?.medias!)!
        stopActivityIndicator()
        self.tableView.reloadData()
    }
    
    func requestMediaFilesFailed(data: Data?) {
        showAlertView(title: "Falha", message: "Não foi possível obter os dados")
        stopActivityIndicator()
    }
}

// MARK: - UITableViewDataSource
extension MediaViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaFileCell", for: indexPath) as! MediaFilesTableViewCell
        
        let media = medias[(indexPath as NSIndexPath).row]
        
        cell.name.text = media.name
        
        cell.indicatorDownload.isHidden = !media.showProgress
                
        let imageUrl = baseAssets + "/" + media.image!
        
        cell.mediaImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell
    }
}

// MARK: - Finish Download Event
extension MediaViewController: MediaDownloadDelegate {
    
    func finishDownload(currentPath: String, assetName: String, isSucess: Bool) {
    
        if let i = medias.index(where: { $0.video == assetName }) {
            medias[i].showProgress = false
            tableView.reloadData()
        }
        
        IJProgressView.shared.hideProgressView()

        if (isSucess) {
            
            showAlertView(title: "Sucesso", message: "Arquivo salvo com sucesso")
            
        } else {
            
            showAlertView(title: "Falha", message: "Não foi possível completar o download desse arquivo")
        }
    }
}

// MARK: - UITableViewDelegate
extension MediaViewController: UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let media = self.medias[(indexPath as NSIndexPath).row]
        let mediaName = media.video!
        let mediaUrl = self.baseAssets + "/" + mediaName
        
        let alert = UIAlertController(title: "Opções", message: "Escolha uma opção", preferredStyle: .actionSheet)
        alert.message = nil
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Assistir", style: .default, handler: { (action) in
            
            self.performSegue(withIdentifier: "proxima", sender: indexPath)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title:"Download", style: .default, handler: { (action) in
            
            media.showProgress = true
            
            tableView.reloadData()
            
            self.startDownload(url: mediaUrl, assetName: mediaName)
        }))
        
        DispatchQueue.main.async() {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "proxima") {
        
            let destination = segue.destination as! MultiMediaViewController

            destination.baseAsset = baseAssets
            destination.medias = medias
            destination.currentMidia = medias[(sender as! NSIndexPath).row]
        }
    }
}
